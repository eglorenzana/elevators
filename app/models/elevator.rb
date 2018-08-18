class Elevator < ApplicationRecord
  attr_accessor :keycard

  def receive_keycard(keycard)
    @keycard = keycard
  end

  def remove_keycard()
    @keycard = nil
  end
  
end
