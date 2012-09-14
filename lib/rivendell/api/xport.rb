module Rivendell::API
  class Xport
    include HTTMultiParty
    base_uri 'http://localhost/rd-bin/rdxport.cgi'
    # debug_output $stderr
    format :xml

    COMMAND_EXPORT = 1
    COMMAND_IMPORT = 2
    COMMAND_DELETEAUDIO = 3
    COMMAND_LISTGROUPS = 4
    COMMAND_LISTGROUP = 5
    COMMAND_LISTCARTS = 6
    COMMAND_LISTCART = 7
    COMMAND_LISTCUT = 8
    COMMAND_LISTCUTS = 9
    COMMAND_ADDCUT = 10
    COMMAND_REMOVECUT = 11
    COMMAND_ADDCART = 12
    COMMAND_REMOVECART = 13
    COMMAND_EDITCART = 14
    COMMAND_EDITCUT = 15
    COMMAND_EXPORT_PEAKS = 16

    def logger
      Rivendell::API.logger
    end

    def query(command, attributes = {})
      attributes = { 
        :command => command, 
        :login_name => "user", 
        :password => "" 
      }.merge(attributes)

      attributes.inject({}) do |map, (key, value)|
        map[key.to_s.upcase] = value
        map
      end
    end

    def post(command, attributes = {}, options = {})
      logger.debug "Post #{command} #{attributes.inspect}"
      self.class.post '', :query => query(command, attributes)
    end

    def list_groups
      post COMMAND_LISTGROUPS
    end

    def add_cart(attributes = {})
      attributes = { :type => "audio" }.merge(attributes)
      attributes[:group_name] ||= attributes.delete(:group)

      response = post COMMAND_ADDCART, attributes
      Rivendell::API::Cart.new(response["cartAdd"]["cart"])
    end

    def list_carts(options = {})
      # accents in carts create invalid UTF-8 response
      post COMMAND_LISTCARTS, options
    end

    def remove_cart(cart_number)
      post COMMAND_REMOVECART, :cart_number => cart_number
    end

    def import(cart_number, cut_number, file, options = {})
      arguments = { 
        :channels => 2, 
        :normalization_level => -13,
        :autotrim_level => -30,
        :use_metadata => true,
      }.merge(options)

      arguments = arguments.merge(:cart_number => cart_number, :cut_number => cut_number, :filename => File.new(file))

      arguments[:use_metadata] = 1 if arguments[:use_metadata]

      post COMMAND_IMPORT, arguments, :timeout => 10*60
    end

    def add_cut(cart_number)
      response = post COMMAND_ADDCUT, :cart_number => cart_number
      Rivendell::API::Cut.new(response["cutAdd"]["cut"])
    end

  end
end