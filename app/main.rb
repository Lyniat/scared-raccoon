module Constants
  WIDTH = 1280
  HEIGHT = 720
  SPRITE_SIZE = 160
  GRAVITY = -1
  JUMP_FORCE = -27
  SNAKE_SPEED = 14
end

module State
  START = 0
  RUNNING = 1
  GAME_OVER = 2
end

def init
  @gravity = 0
  @x = Constants::WIDTH / 4
  @y = 0

  @snake_x = Constants::WIDTH * 2
  @snake_speed = Constants::SNAKE_SPEED

  @state = State::START
  @points = 0
  @got_point = false

end

def tick args
  if args.state.tick_count == 0
    init
    args.outputs.sounds << "sounds/music.ogg"
  end

  case @state
  when State::START
    args.outputs.labels  << [Constants::WIDTH / 2, Constants::HEIGHT * 0.75, "SCARED RACCOON", 30, 1]

    args.outputs.labels  << [Constants::WIDTH * 0.97, Constants::HEIGHT * 0.95, "code: lyniat", 5, 2]
    args.outputs.labels  << [Constants::WIDTH * 0.97, Constants::HEIGHT * 0.9, "graphics: WauWauGirly", 5, 2]
    args.outputs.labels  << [Constants::WIDTH * 0.97, Constants::HEIGHT * 0.85, "music: Martin Zalecki", 5, 2]

    args.outputs.labels  << [Constants::WIDTH / 2, Constants::HEIGHT * 0.6, "select: \"enter\" ", 5, 1]
    args.outputs.labels  << [Constants::WIDTH / 2, Constants::HEIGHT * 0.55, " jump: \"space\"", 5, 1]

    if args.inputs.keyboard.key_down.enter
      @state = State::RUNNING
      args.outputs.sounds << "sounds/select.wav"
    end
  when State::RUNNING
    @gravity += 1

    if args.inputs.keyboard.key_down.space && @y == 0
      @gravity = Constants::JUMP_FORCE
      args.outputs.sounds << "sounds/jump.wav"
    end

    @y -= @gravity
    @y = 0 if @y < 0

    @snake_x -= @snake_speed * Math.sin(args.state.tick_count / 20).abs
    if @snake_x < -Constants::SPRITE_SIZE
      @snake_x = Constants::WIDTH + rand * Constants::WIDTH
      @snake_speed = (Constants::SNAKE_SPEED + rand * Constants::SNAKE_SPEED + @points / 2)
      @got_point = false
    end

    if @snake_x + Constants::SPRITE_SIZE < @x && !@got_point
      @got_point = true
      @points += 1
    end

    if args.geometry.intersect_rect?( [@x, @y, Constants::SPRITE_SIZE * 0.75, Constants::SPRITE_SIZE] ,[@snake_x, 0, Constants::SPRITE_SIZE * 0.75, Constants::SPRITE_SIZE * 0.75])
      @snake_speed = 0
      args.outputs.sounds << "sounds/hit.wav"
      @state = State::GAME_OVER
    end

  when State::GAME_OVER
    args.outputs.labels  << [Constants::WIDTH / 2, Constants::HEIGHT * 0.75, "GAME OVER", 30, 1]

    if args.inputs.keyboard.key_down.enter
      args.outputs.sounds << "sounds/select.wav"
      init
      @state = State::START
    end
  end

  args.outputs.labels  << [0, Constants::HEIGHT, "Points: #{@points}", 15, 0]
  args.outputs.sprites << [@x, @y, Constants::SPRITE_SIZE, Constants::SPRITE_SIZE, "sprites/raccoon.png"]
  args.outputs.sprites << [@snake_x, 0, Constants::SPRITE_SIZE, Constants::SPRITE_SIZE, "sprites/snake.png"]

  args.outputs.sprites << [0, 0, Constants::WIDTH, Constants::HEIGHT, "sprites/front.png"]
end