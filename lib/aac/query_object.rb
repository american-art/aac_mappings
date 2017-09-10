module AAC
  class QueryObject
    self::DEFAULT_PREFIXES = {
        owl:    "http://www.w3.org/2002/07/owl#",
        rdf:    "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
        rdfs:   "http://www.w3.org/2000/01/rdf-schema#",
        crm:    "http://erlangen-crm.org/current/",
        skos:   "http://www.w3.org/2004/02/skos/core#",
        xsd:    "http://www.w3.org/2001/XMLSchema#",
        foaf:   "http://xmlns.com/foaf/0.1/",
        dct:    "http://purl.org/dc/terms/",
        dc:     "http://purl.org/dc/elements/1.1/",
        schema: "http://schema.org/"
    }

    def self.prefix_list(prefixes = {})
      prefixes = {} if prefixes.nil?
      DEFAULT_PREFIXES.merge(prefixes).collect {|key,value| "PREFIX #{key}: <#{value}>"}.join("\n")
    end

    attr_accessor :select, :construct, :where, :prefixes, :ask
    attr_writer :values

    def initialize(obj = {})
      @obj = obj
      self.ask       = obj.fetch("ask"       , nil)
      self.select    = obj.fetch("select"    , nil)
      self.construct = obj.fetch("construct" , nil)
      self.where     = obj.fetch("where"     , nil)
      self.values    = obj.fetch("values"    , nil)
    end

    #--------------------------------------------------------------------------
    # Depriciated—Doing this the hard way.  See #replace_values
    def values(args)
      parameters = @values.split(" ").collect do |parameter|
        key_value = parameter.gsub("?","")
        args.has_key?(key_value) ? "<#{args[key_value]}>" : nil
      end.compact.join(" ")

      "VALUES (#{@values}) {(#{parameters})}" 
    end


    #--------------------------------------------------------------------------
    def replace_values(query, args) 

      @values.split(" ").each do |parameter|
        key_value = parameter.gsub("?","")
      query.gsub!(parameter, "<#{args[key_value]}>") if args.has_key?(key_value)
      end
      query
    end

    #--------------------------------------------------------------------------
    def where_clause(include_construct = false)
      if @where
        str = "WHERE {\n"
        str += "{" if include_construct
        str += @where
        str += "\n} UNION {\n#{construct_as_where}\n}" if include_construct
        str += "\n}"
      else
        <<~eos
          WHERE {
            #{@construct}        
          }
        eos
      end
    end
    def construct_as_where
       val = @construct.gsub("_:","_:construct_")
    end

    #--------------------------------------------------------------------------
    def construct_query(args)
      query = <<~eos
        #{QueryObject.prefix_list(@prefixes)}

        CONSTRUCT {
          #{@construct}
        }
        #{where_clause}
      eos
      replace_values(query, args)
    end

    #--------------------------------------------------------------------------
    def select_query(args)
      query = <<~eos
        #{QueryObject.prefix_list(@prefixes)}
 
        SELECT #{@select}
        #{where_clause}

      eos
      replace_values(query, args)
    end

    #--------------------------------------------------------------------------
    def ask_query(args)
      query = <<~eos
        #{QueryObject.prefix_list(@prefixes)}
    
        ASK {#{@ask}}
      eos
      replace_values(query, args)
    end
  end
end