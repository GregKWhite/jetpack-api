module API
  class IssueOrderer
    def initialize(order)
      @order = order.map(&:to_i)
    end

    def call
      issue_hash = Issue.find(order).index_by(&:id)
      change_orders(issue_hash)
      save_issues(issue_hash).sort { |a, b| a.order <=> b.order }
    end

    protected

    attr_reader :order

    private

    def change_orders(issue_hash)
      order.each_with_index do |id, pos|
        issue_hash[id].order = pos
      end
    end

    def save_issues(issue_hash)
      issue_hash.values.tap do |issues|
        Issue.transaction { issues.each(&:save!) }
      end
    end
  end
end
