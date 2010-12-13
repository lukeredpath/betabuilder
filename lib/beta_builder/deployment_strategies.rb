require 'beta_builder/deployment_strategies/web'

module BetaBuilder
  module DeploymentStrategies
    def self.valid_strategy?(strategy_name)
      strategies.keys.include?(strategy_name.to_sym)
    end

    def self.build(strategy_name, configuration)
      strategies[strategy_name.to_sym].new(configuration)
    end

    private

    def self.strategies
      {:web => Web}
    end
  end
end

