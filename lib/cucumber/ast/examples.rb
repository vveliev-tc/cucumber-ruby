require 'cucumber/ast/names'

module Cucumber
  module Ast
    class Examples #:nodoc:
      include Names
      include HasLocation
      attr_reader :comment, :keyword, :outline_table

      def initialize(location, comment, keyword, title, description, outline_table)
        @location, @comment, @keyword, @title, @description, @outline_table = location, comment, keyword, title, description, outline_table
        raise ArgumentError unless @location.is_a?(Location)
        raise ArgumentError unless @comment.is_a?(Comment)
      end

      attr_reader :gherkin_statement
      def gherkin_statement(statement=nil)
        @gherkin_statement ||= statement
      end

      def describe_to(visitor)
        visitor.examples_table(self) do
          children.each do |child|
            child.describe_to(visitor)
          end
        end
      end

      def children
        @outline_table.cells_rows[1..-1]
      end

      def accept(visitor)
        visitor.visit_examples(self) do
          comment.accept(visitor)
          visitor.visit_examples_name(keyword, name)
          outline_table.accept(visitor)
        end
      end

      def skip_invoke!
        @outline_table.skip_invoke!
      end

      def each_example_row(&proc)
        @outline_table.cells_rows[1..-1].each(&proc)
      end

      def failed?
        @outline_table.cells_rows[1..-1].select{|row| row.failed?}.any?
      end

      def to_sexp
        sexp = [:examples, @keyword, name]
        comment = comment.to_sexp
        sexp += [comment] if comment
        sexp += [@outline_table.to_sexp]
        sexp
      end
    end
  end
end
