module Skynet
  module SkynetHelper

   def render_str(value, prefix='',suffix='',separator=': ')
      if value.kind_of?(Array)      
	return [prefix,separator,value.to_s,suffix,"\n"].join unless value.empty?
      elsif value.kind_of?(String)
	return [prefix,separator,value,suffix,"\n"].join unless value.empty?
      else
	return [prefix,separator,value,suffix,"\n"].join
      end
    return nil
   end

  end
end
