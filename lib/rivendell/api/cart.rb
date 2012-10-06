require 'active_support/core_ext/string/inflections'

module Rivendell::API
  class Cart
   
    attr_accessor :number, :type, :group_name, :title, :artist, :album, :year, :label, :client, :agency, :publisher, :composer, :user_defined, :usage_code, :forced_length, :average_length, :length_deviation, :average_segue_lenth, :average_hook_length, :cut_quantity, :last_cut_played, :validity, :enforce_length, :asyncronous, :owner, :metadata_datetime

    def initialize(attributes = {})
      attributes.each { |k,v| send "#{k}=", v }
    end

    def number=(number)
      @number = (number ? number.to_i : nil)
    end
    
    alias_method :group, :group_name
    alias_method :group=, :group_name=
      
    def cut_list=(cuts)
      
    end

    def macro_list=(cuts)
      
    end

    def method_missing(name, *arguments)
      underscored_name = name.to_s.underscore
      if respond_to?(underscored_name)
        send underscored_name, *arguments
      else
        super
      end
    end
 
  end
end
