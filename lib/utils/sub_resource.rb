# frozen_string_literal: true

module StarkCore
  module Utils
    class SubResource    
      def to_s
        string_vars = []
        instance_variables.each do |key|
          value = instance_variable_get(key).to_s.lines.map(&:chomp).join("\n  ")
          string_vars << "#{key[1..-1]}: #{value}"
        end
        fields = string_vars.join(",\n  ")
        "#{class_name}(\n  #{fields}\n)"
      end
      
      def class_name
        self.class.name.split('::').last.downcase
      end
    end
  end
end
