class Object
  def cast_to clazz
    object =  Object.const_defined?(clazz) ? Object.const_get(clazz) : String
    
    case 
      when object == TrueClass;  true
      when object == FalseClass; false
      when object == NilClass;   nil
      when object == Fixnum || object == Bignum; self.to_i
      when object == Float; self.to_f
      when object == Enumerator; self.to_enum
      when object == Complex; self.to_c
      when object == Rational; self.to_r
      else self.to_s
    end
  end
end  
