require "test_helper"

module HubKernel
  class PortAssociationsTest < ActiveSupport::TestCase
    module Sales
      extend HubKernel::Ports

      record_port :job_record
      record_port :quote_record
    end

    module Pipelines
      extend HubKernel::Ports

      record_port :job_record
      record_port :quote_record
    end

    class Job < ActiveRecord::Base
      self.table_name = "port_jobs"

      has_many_port :quotes, port: Sales, record: :quote_record
      has_many_port :priced_quotes, port: Sales, record: :quote_record, foreign_key: :job_id, inverse_of: false, validate: false, strict_loading: true
    end

    Sales.job_record = Job

    class Quote < ActiveRecord::Base
      self.table_name = "port_quotes"

      belongs_to_port :job, port: Sales, record: :job_record
      belongs_to_port :first_job, port: Sales, record: :job_record, foreign_key: :job_id, optional: true, inverse_of: false
      belongs_to_port :roofing_job, -> { where(name: "Roof") }, port: Sales, record: :job_record, foreign_key: :job_id, optional: true
      belongs_to_port :wanted_job, ->(quote) { where(name: quote.wanted) }, port: Sales, record: :job_record, foreign_key: :job_id, optional: true
    end

    Sales.quote_record = Quote

    setup do
      connection = ActiveRecord::Base.connection
      connection.create_table(:port_jobs, force: true) { |table| table.string :name }
      connection.create_table(:port_quotes, force: true) { |table| table.references :job; table.string :wanted }
    end

    teardown do
      Pipelines.job_record = nil
      Pipelines.quote_record = nil
    end

    test "a model reads the record its link points at the way it reads any belongs_to" do
      job = Job.create!(name: "Roof")

      assert_equal job, Quote.create!(job_id: job.id).job
    end

    test "linked records can be preloaded, joined, filtered and ordered on" do
      roof, deck, shed = %w[Roof Deck Shed].map { |name| Job.create!(name: name) }
      [ roof, deck, shed ].each { |job| Quote.create!(job_id: job.id) }

      quotes = Quote.includes(:job).joins(:job).where(job: { name: %w[Roof Deck] }).order(job: { name: :asc })

      assert_equal [ deck, roof ], quotes.map(&:job)
    end

    test "a model that loads after its port is filled has the link as soon as it loads" do
      assert_equal Job, Quote.reflect_on_association(:job)&.klass
    end

    test "a model that loads before its port is filled has the link as soon as the port is filled" do
      plan = self.class.const_set(:Plan, Class.new(ActiveRecord::Base) { self.table_name = "port_quotes" })
      plan.belongs_to_port :job, port: Pipelines, record: :job_record

      Pipelines.job_record = Job

      assert_equal Job, plan.reflect_on_association(:job)&.klass
    end

    test "every option a belongs_to takes other than its class name reaches the association" do
      options = Quote.reflect_on_association(:first_job).options

      assert_equal({ foreign_key: :job_id, optional: true, inverse_of: false }, options.slice(:foreign_key, :optional, :inverse_of))
    end

    test "saving or destroying a record read through the link raises a read-only error" do
      job = Job.create!(name: "Roof")
      quote = Quote.create!(job_id: job.id)
      linked = [ Quote.find(quote.id).job, Quote.preload(:job).find(quote.id).job, Quote.eager_load(:job).find(quote.id).job ]

      assert_equal [ ActiveRecord::ReadOnlyRecord ] * 6, linked.flat_map { |record| [ refusal { record.update!(name: "Deck") }, refusal { record.destroy } ] }
    end

    test "building or creating a linked record through the link raises a read-only error" do
      quote = Quote.new
      attempts = [ -> { quote.build_job(name: "Roof") }, -> { quote.create_job(name: "Roof") }, -> { quote.create_job!(name: "Roof") }, -> { quote.update(job: Job.new(name: "Roof")) } ]

      assert_equal [ ActiveRecord::ReadOnlyRecord ] * 4, attempts.map { |attempt| refusal(&attempt) }
    end

    test "a model can set which record it links to and save itself" do
      roof, deck = %w[Roof Deck].map { |name| Job.create!(name: name) }
      quote = Quote.includes(:job).find(Quote.create!(job: roof).id)

      quote.update!(job: deck)

      assert_equal deck.id, Quote.find(quote.id).job_id
    end

    test "a scope the declaration passes is applied and the records it loads are still read-only" do
      roof, deck = %w[Roof Deck].map { |name| Job.create!(name: name) }
      quotes = [ roof, deck ].map { |job| Quote.create!(job: job) }

      assert_equal [ [ "Roof", true ], nil ], quotes.map { |quote| Quote.find(quote.id).roofing_job&.then { |job| [ job.name, job.readonly? ] } }
    end

    test "a scope the declaration passes that reads the model's own record is applied and its records are still read-only" do
      roof, deck = %w[Roof Deck].map { |name| Job.create!(name: name) }
      quotes = [ roof, deck ].map { |job| Quote.create!(job: job, wanted: "Roof") }

      assert_equal [ [ "Roof", true ], nil ], quotes.map { |quote| Quote.find(quote.id).wanted_job&.then { |job| [ job.name, job.readonly? ] } }
    end

    test "no option passed to the declaration makes a linked record writable" do
      model = self.class.const_set(:Order, Class.new(ActiveRecord::Base) { self.table_name = "port_quotes" })
      writing = { autosave: true, dependent: :destroy, touch: true, counter_cache: true }

      refusals = writing.map do |option, value|
        model.belongs_to_port(:job, port: Sales, record: :job_record, option => value)
        nil
      rescue ArgumentError => error
        error.message
      end

      assert_equal writing.keys.map { |option| "job is a read-only record port link, so it does not take #{option}" }, refusals
    end

    test "a model lists the records that point back at it through a has-many link the way it lists any has_many" do
      job = Job.create!(name: "Roof")
      quotes = Array.new(2) { Quote.create!(job_id: job.id) }

      assert_equal quotes, job.quotes.sort_by(&:id)
    end

    test "listed records can be preloaded, joined, filtered and ordered on" do
      roof, deck, shed = %w[Roof Deck Shed].map { |name| Job.create!(name: name) }
      [ roof, deck, shed ].each { |job| Quote.create!(job_id: job.id, wanted: job.name) }

      jobs = Job.includes(:quotes).joins(:quotes).where(quotes: { wanted: %w[Roof Deck] }).order(quotes: { wanted: :asc })

      assert_equal [ [ "Deck" ], [ "Roof" ] ], jobs.map { |job| job.quotes.map(&:wanted) }
    end

    test "every option a has_many takes other than its class name reaches the has-many link" do
      options = Job.reflect_on_association(:priced_quotes).options

      assert_equal({ foreign_key: :job_id, inverse_of: false, validate: false, strict_loading: true }, options.slice(:foreign_key, :inverse_of, :validate, :strict_loading))
    end

    test "a model that loads after its port is filled has the has-many link as soon as it loads" do
      crew = self.class.const_set(:Crew, Class.new(ActiveRecord::Base) { self.table_name = "port_jobs" })
      crew.has_many_port :quotes, port: Sales, record: :quote_record, foreign_key: :job_id

      assert_equal Quote, crew.reflect_on_association(:quotes)&.klass
    end

    test "a model that loads before its port is filled has the has-many link as soon as the port is filled" do
      team = self.class.const_set(:Team, Class.new(ActiveRecord::Base) { self.table_name = "port_jobs" })
      team.has_many_port :quotes, port: Pipelines, record: :quote_record, foreign_key: :job_id

      Pipelines.quote_record = Quote

      assert_equal Quote, team.reflect_on_association(:quotes)&.klass
    end

    test "saving or destroying a record listed through the has-many link raises a read-only error" do
      job = Job.create!(name: "Roof")
      Quote.create!(job_id: job.id)
      listed = [ Job.find(job.id).quotes.first, Job.find(job.id).quotes.to_a.first, Job.preload(:quotes).find(job.id).quotes.first, Job.eager_load(:quotes).find(job.id).quotes.first ]

      assert_equal [ ActiveRecord::ReadOnlyRecord ] * 8, listed.flat_map { |record| [ refusal { record.update!(wanted: "Deck") }, refusal { record.destroy } ] }
    end

    private

    def refusal
      yield
      nil
    rescue ActiveRecord::ActiveRecordError => error
      error.class
    end
  end
end
