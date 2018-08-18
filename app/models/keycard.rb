class NoBuildingDefined < StandardError
  def message
    "No building is defined. Assign a building for this."
  end
end

class Keycard < ApplicationRecord
  belongs_to :building


  # resolver interface: manage the credentials to access a building and its stories
  # move to a different file if there are more resolvers, and then mix in

  def have_access_to?(floor)
    self[:floors].include?(floor)
  end

  def self.create_for(building, *floors, **options)
    keycard = build_for(building, *floors, **options);
    keycard.save()
  end

  def self.build_for(building, *floors, **options)
    _floors = options[:all] ? [] : floors
    keycard = new({building: building, all: options[:all]})
    keycard.give_access_to(*_floors);
    keycard
  end

  def give_access_to(*floors)
    raise NoBuildingDefined unless building_present?
    valid_floors = floors.select { |f| building.is_valid_floor?(f) }
    self[:floors] = self[:floors] | valid_floors
  end

  def remove_access_to(*floors)
    self[:floors] -= floors
  end

  def accesToBuilding?(target)
    building == target
  end

  def building_present?
    building ? true : false
  end
end
