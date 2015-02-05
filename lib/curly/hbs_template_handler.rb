class Curly::HbsTemplateHandler < Curly::TemplateHandler
  class << self
    def call(template)
      instrument(template) do
        compile(template, :hbs)
      end
    end
  end
end
