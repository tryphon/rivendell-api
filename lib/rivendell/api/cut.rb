require 'active_support/core_ext/string/inflections'

module Rivendell::API
  class Cut

    attr_accessor :name, :number, :cart_number, :evergreen, :description, :outcue, :isrc, :isci, :length, :origin_datetime, :start_datetime, :end_datetime, :sun, :mon, :tue, :wed, :thu, :fri, :sat, :start_daypart, :end_daypart, :origin_name, :weight, :last_play_datetime, :play_counter, :local_counter, :validity, :coding_format, :sample_rate, :bit_rate, :channels, :play_gain, :start_point, :end_point, :fadeup_point, :fadedown_point, :segue_start_point, :segue_end_point, :segue_gain, :hook_start_point, :hook_end_point, :talk_start_point, :talk_end_point

    def initialize(attributes = {})
      attributes.each { |k,v| send "#{k}=", v }
    end

    def number=(number)
      @number = (number ? number.to_i : nil)
    end

    alias_method :cut_name=, :name=
    alias_method :cut_number=, :number=

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
    
