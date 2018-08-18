class Building < ApplicationRecord


  def set_floor_name(floor, name)
    is_valid_floor?(floor) && self[:floor_naming][floor] = name
  end

  def get_floor_name(floor)
    return nil unless is_valid_floor?(floor)
    name = self[:floor_naming][floor]
    if (!name)
      name = floor >= 0 ? "Floor #{floor}" : "Basement #{-floor}"
    end
    name
  end

  def is_valid_floor?(floor)
    return false if floor == 0
    (-self[:below_floors]..self[:above_floors]).include?(floor)
  end

  def getFloorRange(floor1, floor2)
    min, max = (floor1 < floor2) ? [floor1, floor2] : [floor2, floor1]
    min += 1 until is_valid_floor?(min)
    max -= 1 until is_valid_floor?(max)
    floors = (min..max).to_a
    floors.delete(0)
    floors
  end

end
