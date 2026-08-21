#===============================================================================
# Deltarune Battle
# 010_Handlers.rb
#===============================================================================

module DeltaruneBattle
  module Handlers
    #---------------------------------------------------------------------------
    # Armazenamento dos handlers
    #---------------------------------------------------------------------------

    @handlers = {}

    #---------------------------------------------------------------------------
    # Registrar um handler
    #---------------------------------------------------------------------------

    def self.add(event, key, &block)
      return if !block

      @handlers[event] ||= {}
      @handlers[event][key] = block
    end

    #---------------------------------------------------------------------------
    # Remover um handler
    #---------------------------------------------------------------------------

    def self.remove(event, key)
      return if !@handlers[event]

      @handlers[event].delete(key)
    end

    #---------------------------------------------------------------------------
    # Verificar se existe algum handler
    #---------------------------------------------------------------------------

    def self.has?(event)
      return false if !@handlers[event]

      !@handlers[event].empty?
    end

    #---------------------------------------------------------------------------
    # Executar handlers
    #---------------------------------------------------------------------------

    def self.trigger(event, *args)
      return if !@handlers[event]

      @handlers[event].each_value do |handler|
        handler.call(*args)
      end
    end

    #---------------------------------------------------------------------------
    # Limpar handlers
    #---------------------------------------------------------------------------

    def self.clear(event = nil)
      if event
        @handlers.delete(event)
      else
        @handlers.clear
      end
    end
  end
end