module DeploymentStrategies
  def self.valid?(strategy_name)
    strategies.keys.include?(key.to_sym)
  end
  
  def self.build(strategy_name, configuration)
    strategies[strategy_name.to_sym].new(configuration)
  end
  
  private
  
  def self.strategies
    {:web => Web}
  end
end
