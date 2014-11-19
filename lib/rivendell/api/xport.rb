module Rivendell::API
  class Xport
    include HTTMultiParty

    debug_output $stderr
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

    def initialize(options = {})
      options.each { |k,v| send "#{k}=", v }
    end

    attr_accessor :login_name, :password, :host

    def host
      @host ||= "localhost"
    end

    def login_name
      @login_name ||= "user"
    end

    def password
      @password ||= ""
    end

    def rdxport_uri
      "http://#{host}/rd-bin/rdxport.cgi"
    end

    def query(command, attributes = {})
      attributes = {
        :command => command,
        :login_name => login_name,
        :password => password
      }.merge(attributes)

      attributes.inject({}) do |map, (key, value)|
        map[key.to_s.upcase] = value unless value.nil?
        map
      end
    end

    def post(command, attributes = {}, options = {})
      logger.debug "Post #{command} #{attributes.inspect}"

      options = options.merge :query => query(command, attributes)

      response = self.class.post rdxport_uri, options
      response.error! unless response.success?
      response
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

    def edit_cart(number, attributes = {})
      attributes[:cart_number] = number
      attributes.delete(:number)
      attributes[:group_name] ||= attributes.delete(:group)

      response = post COMMAND_EDITCART, attributes
      Rivendell::API::Cart.new(response["cartList"]["cart"])
    end

    def list_cart(cart_number)
      response = post COMMAND_LISTCART, :cart_number => cart_number
      Rivendell::API::Cart.new response["cartList"]["cart"]
    end

    # FIXME accents in carts create invalid UTF-8 response
    def list_carts(options = {})
      options[:group_name] ||= options.delete(:group)

      response = post COMMAND_LISTCARTS, options
      elements(response["cartList"]["cart"]).collect do |cart_xml|
        Rivendell::API::Cart.new(cart_xml)
      end
    end

    def elements(response)
      case response
      when Array
        response
      when nil
        []
      else
        [ response ]
      end
    end

    def remove_cart(cart_number)
      post COMMAND_REMOVECART, :cart_number => cart_number
    end

    def list_cuts(cart_number)
      response = post COMMAND_LISTCUTS, :cart_number => cart_number
      elements(response["cutList"]["cut"]).collect do |cut_xml|
        Rivendell::API::Cut.new cut_xml
      end
    end

    def remove_cut(cart_number, cut_number)
      post COMMAND_REMOVECUT, :cart_number => cart_number, :cut_number => cut_number
    end

    # Extension
    def clear_cuts(cart_number)
      list_cuts(cart_number).map(&:number).each do |cut_number|
        remove_cut cart_number, cut_number
      end
    end

    def import(cart_number, cut_number, file, options = {})
      timeout = (options.delete(:timeout) || 10)*60

      arguments = {
        :channels => 2,
        :normalization_level => -13,
        :autotrim_level => -30,
        :use_metadata => true,
      }.merge(options)

      arguments = arguments.merge(:cart_number => cart_number, :cut_number => cut_number, :filename => File.new(file))

      arguments[:use_metadata] = 1 if arguments[:use_metadata]

      post COMMAND_IMPORT, arguments, :timeout => timeout
    end

    def add_cut(cart_number)
      response = post COMMAND_ADDCUT, :cart_number => cart_number
      Rivendell::API::Cut.new(response["cutAdd"]["cut"])
    end

    def edit_cut(cart_number, cut_number, attributes = {})
      attributes[:cart_number] = cart_number
      attributes[:cut_number] = cut_number

      post COMMAND_EDITCUT, attributes
    end

    def list_cut(cart_number, cut_number)
      arguments = {
        :cart_number => cart_number,
        :cut_number => cut_number
      }

      response = post COMMAND_LISTCUT, arguments
      Rivendell::API::Cut.new(response["cutList"]["cut"])
    end

  end

end
