require 'curly/attribute_parser'

module Curly
  class ReferenceCompiler
    attr_reader :presenter_class, :method, :reference, :argument, :attributes

    def initialize(presenter_class, reference)
      @presenter_class, @reference = presenter_class, reference
      @method, @argument, rest = parse_name_and_parameter
      @attributes = AttributeParser.parse(rest)
    end

    def compile_reference
      compile
    end

    def compile_conditional
      unless method.end_with?("?")
        raise Curly::Error, "not a valid conditional block: `#{reference}`"
      end

      compile
    end

    private

    def parse_name_and_parameter
      name, rest = reference.split(/\s+/, 2)
      method, argument = name.split(".", 2)

      if !method.end_with?("?") && argument && argument.end_with?("?")
        method << "?"
        argument = argument[0..-2]
      end

      [method, argument, rest]
    end

    def compile
      unless presenter_class.method_available?(method)
        raise Curly::InvalidReference.new(method)
      end

      validate_attributes(attributes)

      code = "presenter.#{method}("

      append_positional_argument(code, argument)
      append_keyword_arguments(code, argument, attributes)

      code << ")"
    end

    def append_positional_argument(code, argument)
      if required_parameter?
        if argument.nil?
          raise Curly::Error, "`#{method}` requires a parameter"
        end

        code << argument.inspect
      elsif optional_parameter?
        code << argument.inspect unless argument.nil?
      elsif invalid_signature?
        raise Curly::Error, "`#{method}` is not a valid reference method"
      elsif !argument.nil?
        raise Curly::Error, "`#{method}` does not take a parameter"
      end
    end

    def append_keyword_arguments(code, argument, attributes)
      keyword_argument_string = build_keyword_argument_string(attributes)

      unless keyword_argument_string.empty?
        code << ", " unless argument.nil?
        code << keyword_argument_string
      end
    end

    def invalid_signature?
      positional_params = param_types.select {|type| [:req, :opt].include?(type) }
      positional_params.size > 1
    end

    def required_parameter?
      param_types.include?(:req)
    end

    def optional_parameter?
      param_types.include?(:opt)
    end

    def build_keyword_argument_string(kwargs)
      kwargs.map {|name, value| "#{name}: #{value.inspect}" }.join(", ")
    end

    def validate_attributes(kwargs)
      kwargs.keys.each do |key|
        unless attribute_names.include?(key)
          raise Curly::Error, "`#{method}` does not allow attribute `#{key}`"
        end
      end

      required_attribute_names.each do |key|
        unless kwargs.key?(key)
          raise Curly::Error, "`#{method}` is missing the required attribute `#{key}`"
        end
      end
    end

    def params
      @params ||= presenter_class.instance_method(method).parameters
    end

    def param_types
      params.map(&:first)
    end

    def attribute_names
      @attribute_names ||= params.
        select {|type, name| [:key, :keyreq].include?(type) }.
        map {|type, name| name.to_s }
    end

    def required_attribute_names
      @required_attribute_names ||= params.
        select {|type, name| type == :keyreq }.
        map {|type, name| name.to_s }
    end
  end
end
