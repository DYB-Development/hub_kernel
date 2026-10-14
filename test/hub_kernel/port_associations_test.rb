require "test_helper"

module HubKernel
  class PortAssociationsTest < ActiveSupport::TestCase
    module Sales
      extend HubKernel::Ports

      record_port :job_record
    end

    class Job < ActiveRecord::Base
      self.table_name = "port_jobs"
    end

    Sales.job_record = Job

    class Quote < ActiveRecord::Base
      self.table_name = "port_quotes"

      belongs_to_port :job, port: Sales, record: :job_record
    end

    setup do
      connection = ActiveRecord::Base.connection
      connection.create_table(:port_jobs, force: true) { |table| table.string :name }
      connection.create_table(:port_quotes, force: true) { |table| table.references :job }
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
  end
end
