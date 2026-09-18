module HubKernel
  module Markup
    def markup_path(within: "app/views")
      File.join(root.to_s, within, "**", "*.erb")
    end
  end
end
