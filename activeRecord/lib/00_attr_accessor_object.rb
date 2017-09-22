require "byebug"
class AttrAccessorObject
  def self.my_attr_accessor(*names)
    # debugger
    names.each do |arg|
      define_method(arg) { instance_variable_get("@#{arg}")  }
      define_method("#{arg}=") {|value| instance_variable_set("@#{arg}", value)  }
    end

  end





end
