CONSTRAINTS_TYPES = [ :keycard ]
GENERAL_CONSTRAINTS = {
  all: ->(elevatorManager, floor) { return true},
  floors: ->(elevatorManager, floor) { return floor > 0},
  basements: ->(elevatorManager, floor) { return floor < 0}
}

class ElevatorManager < ApplicationRecord
  belongs_to :building
  belongs_to :elevator
  attr_accessor :current_weight
  attr_accessor :train

  after_initialize :init_train

  def init_train
    @train = []
    @current_weight = 0
  end

  # interaction with customer

  def request_on(floor)
    building.is_valid_floor?(floor) && push_in_train(floor)
  end

  def request_to(floor)
    building.is_valid_floor?(floor) && can_request_to?(floor) && push_in_train(floor)
  end

  def current_weight=(lb)
    lb >= 0 && @current_weight = lb
    @current_weight
  end


  # movement

  def move
    can_move? && perform_move
  end

  def position
    self[:current_position]
  end


  # manage constraints based on building

  def add_floor_constraint(floor, constraint_type)
    self[:floor_constraints] ||= {}
    if(building &&
      (GENERAL_CONSTRAINTS.keys.include?(floor) || building.is_valid_floor?(floor)) &&
      CONSTRAINTS_TYPES.include?(constraint_type))
      self[:floor_constraints][floor] = constraint_type
    end
    self[:floor_constraints]
  end

  def remove_floor_contraints(floor)
    self[:floor_constraints] && self[:floor_constraints].delete(floor)
  end


  def can_move?
     elevator && @current_weight <= elevator.max_weight
  end

  def getTargetIndex(current)
    #here we can find the neares to the current position,
    # or any other algorithm to choose the target
    index = find_insert_index(train, current)  #for simplicity
    train[index] ?  index : index-1
  end

  def perform_move
    current = self[:current_position]
    index = getTargetIndex(current)
    target = train[index];
    if (target)
      p "Moving from #{building.get_floor_name(current)} to #{building.get_floor_name(target)}"
      floors = building.getFloorRange(current, target);
      method = target > current ? floors.each : floors.reverse_each
      method.each do |floor|
        p "Current: #{building.get_floor_name(floor)}"
        sleep(0.5)
      end
      p " Arrive to: #{building.get_floor_name(target)}"
      self[:current_position] = target;
      train.slice!(index)
    end
  end

  # verify building and elevator are set
  # get and process the contraints about the floors
  # verify if any resolver can pass the related contraint
  def can_request_to?(floor)
    return false unless (building && elevator)
    constraints = self[:floor_constraints];
    general_keys = GENERAL_CONSTRAINTS.keys & constraints.keys
    keys = general_keys.select{ |k| GENERAL_CONSTRAINTS[k][self, floor] }
    keys.push(floor) if constraints[floor].present?
    return true if (keys.length == 0 && building.is_valid_floor?(floor))
    keys.any? do |k|
      needed_resolver = constraints[k];
      resolver = elevator.method(needed_resolver) && elevator.method(needed_resolver).call()
      resolver && resolver.accesToBuilding?(building) && resolver.have_access_to?(floor)
    end
  end

  def push_in_train(floor)
    return train if train.include?(floor)
    index = find_insert_index(train, floor)
    train.insert(index, floor)
  end

  def find_insert_index(ary, n)
    (0...ary.size).bsearch {|i| ary[i] >= n } || ary.length
  end

end
