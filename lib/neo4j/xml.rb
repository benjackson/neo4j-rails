module Neo4j
  module XML
    def to_xml(*options)
      attributes.to_xml(*options)
    end
  end
end