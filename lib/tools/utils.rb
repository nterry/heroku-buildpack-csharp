module Tools
  module Utils

    def convert_hash_to_use_symbols(hash)
      hash.inject({}) do |memo, (k,v)|
        if v.is_a?(Hash)
          memo[k.to_sym] = convert_hash_to_use_symbols(v)
        elsif v.is_a?(Array)
          memo[k.to_sym] = v.map do |x|
            if x == nil or (not x.is_a?(Hash) and not x.is_a?(Array))
              x
            else
              convert_hash_to_use_symbols(x)
            end
          end
        else
          memo[k.to_sym] = v
        end
        memo
      end
    end

  end
end