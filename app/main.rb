module Constants
  WIDTH = 1280
  HEIGHT = 720
  SPRITE_SIZE = 160
  GRAVITY = -1
  JUMP_FORCE = -23
  SNAKE_SPEED = 14
end

module State
  START = 0
  RUNNING = 1
  GAME_OVER = 2
end

def init
  @gravity = 0
  @x = Constants::WIDTH * 0.25
  @y = 0

  @snake_x = Constants::WIDTH + 200
  @snake_speed = Constants::SNAKE_SPEED

  @state = State::START
  @points = 0
  @got_point = false

end

def tick args
  if args.state.tick_count == 0
    init
    args.audio[:bg_music] = { input: "sounds/music.ogg", looping: true }
  end

  case @state
  when State::START
    args.outputs.labels  << {x: Constants::WIDTH * 0.5,
                             y: Constants::HEIGHT - 250,
                             text: "SCARED RACCOON",
                             font: "fonts/manaspc.ttf",
                             size_px: 45,
                             alignment_enum: 1}

    args.outputs.labels  << {x: Constants::WIDTH - 20,
                             y: Constants::HEIGHT - 20,
                             text: "code: lyniat",
                             font: "fonts/manaspc.ttf",
                             size_px: 30,
                             alignment_enum: 2}

    args.outputs.labels  << {x: Constants::WIDTH - 20,
                             y: Constants::HEIGHT - 60,
                             text: "graphics: Streifbert",
                             font: "fonts/manaspc.ttf",
                             size_px: 30,
                             alignment_enum: 2}

    args.outputs.labels  << {x: Constants::WIDTH - 20,
                             y: Constants::HEIGHT - 100,
                             text: "music: Martin Zalecki",
                             font: "fonts/manaspc.ttf",
                             size_px: 30,
                             alignment_enum: 2}

    args.outputs.labels  << {x: Constants::WIDTH * 0.5,
                             y: Constants::HEIGHT - 350,
                             text: "start: \"enter\"",
                             font: "fonts/manaspc.ttf",
                             size_px: 30,
                             alignment_enum: 1}

    args.outputs.labels  << {x: Constants::WIDTH * 0.5,
                             y: Constants::HEIGHT - 400,
                             text: " jump: \"space\"",
                             font: "fonts/manaspc.ttf",
                             size_px: 30,
                             alignment_enum: 1}

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

    if args.geometry.intersect_rect?( [@x + 60, @y, Constants::SPRITE_SIZE * 0.4, Constants::SPRITE_SIZE] ,[@snake_x, 0, Constants::SPRITE_SIZE * 0.75, Constants::SPRITE_SIZE * 0.75])
      @snake_speed = 0
      args.outputs.sounds << "sounds/hit.wav"
      @state = State::GAME_OVER
    end

  when State::GAME_OVER
    args.outputs.labels  << {x: Constants::WIDTH * 0.5,
                             y: Constants::HEIGHT - 250,
                             text: "GAME OVER",
                             font: "fonts/manaspc.ttf",
                             size_px: 60,
                             alignment_enum: 1}
                             
    args.outputs.labels  << {x: Constants::WIDTH * 0.5,
                             y: Constants::HEIGHT - 370,
                             text: "SCORE: #{@points}",
                             font: "fonts/manaspc.ttf",
                             size_px: 35,
                             alignment_enum: 1}

    if args.inputs.keyboard.key_down.enter
      args.outputs.sounds << "sounds/select.wav"
      init
      @state = State::START
    end
  end

  args.outputs.labels  << {x: 20,
                           y: Constants::HEIGHT - 20,
                           text: "SCORE: #{@points}",
                           font: "fonts/manaspc.ttf",
                           size_px: 30,
                           alignment_enum: 0}

  args.outputs.sprites  << {x: @x,
                            y: @y,
                            w: Constants::SPRITE_SIZE,
                            h: Constants::SPRITE_SIZE,
                            path: "sprites/raccoon.png"}

  args.outputs.sprites  << {x: @snake_x,
                            y: 0,
                            w: Constants::SPRITE_SIZE,
                            h: Constants::SPRITE_SIZE,
                            path: "sprites/snake.png"}

  args.outputs.sprites  << {x: 0,
                            y: 0,
                            w: Constants::WIDTH,
                            h: Constants::HEIGHT,
                            path: "sprites/front.png"}
end