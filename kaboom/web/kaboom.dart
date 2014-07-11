import 'dart:html';
import 'dart:math';

KaboomGame game;

class Bomb {
  int x = -1, y = -1;
  DivElement _bomb;
}

class KaboomGame {
  DivElement _game_board;
  DivElement _bomber;
  DivElement _player1;
  DivElement _scoreElement;
  int _board_width = 0;
  int _player_pos = 0;
  int _game_board_height;
  int _bucket_width;
  int _score;
  List _bombs;            // bombs for this level.
  double _bomb_speed;      // rate at whicht he bombs fall
  int _level;             // current level [1..]
  Random _rng = new Random();
  
  KaboomGame() {
    print("KABOOM");
    _game_board = querySelector('#board');
    _player1 = querySelector('#player1');
    _bomber = querySelector('#bomber');
    _scoreElement = querySelector('#score');
    
    _board_width = _game_board.offsetWidth;
    
    _game_board_height = _game_board.offsetHeight;
    _bucket_width = 16;
    print("width=${_board_width} _game_board_height=${_game_board_height} bucket={$_bucket_width}");
    
    
    // the bottom logo bar is also the touch controller surface
    querySelector('#logo-wrapper').onTouchStart.listen(process_finger);
    querySelector('#logo-wrapper').onTouchMove.listen(process_finger);
    querySelector('#logo-wrapper').onMouseMove.listen(process_mouse);
  }
  
  void changeLevel(int levelNum) {
    _level = levelNum;
    
    // This is the max # of bombs on the screen for this
    // level. We'll precreate them in the DOM so we don't 
    // have to do this at runtime.
    _bombs = new List(levelNum * 4);
    for (int i=0; i<_bombs.length; i++) {
      _bombs[i] = new Bomb();
      _bombs[i]
            .._bomb = new DivElement()
            ..x = _rng.nextInt(_board_width)
            ..y = -100 // park it offscreen
            .._bomb.className = 'bomb'
            .._bomb.style.transform = "translate(${_bombs[i].x}px,-100px) translateZ(0)";
      _game_board.children.add(_bombs[i]._bomb);
    }

    _bomb_speed = levelNum * 4.5;
  }

  gameLoop(num delta) {
    _game_board_height = _game_board.offsetHeight;
    // Update the LIVE bomb positions. We know there are
    // falling because the y value is > -1
    int numLive = 0;
    for(final Bomb bomb in _bombs) {
      if (bomb.y > 0) {
        numLive++;
        
        // This bomb is on the gamebaord
        bomb.y += _bomb_speed.toInt();
        
        bomb._bomb.style.transform = "translate(${bomb.x}px,${bomb.y}px) translateZ(0)";
       
        // has bucket gone off the bottom?
        if (bomb.y >= _game_board_height) {
          // TODO level over -- do explosion sequence
          remove_bomb(bomb);
          numLive--;
        }
       
        // Do collision detection with bucket.
        if ( (bomb.y >= (_game_board_height-150)) && (bomb.x - _player_pos).abs() < 40) {
          // bucket has cought a bomb!
          _score++;
          _scoreElement.setInnerHtml("${_score}");
          
          remove_bomb(bomb);
          numLive--;
        }
        
      } // bomb is live
      
    } // foreach(bombs)
    
    
    // Should we add another bomb falling?
    if (numLive < _bombs.length)
      add_bomb();
    
    window.animationFrame.then(gameLoop);
  }
    
  void remove_bomb(Bomb bomb) {
    bomb._bomb.style.transform = "transformY(-100px) translateZ(0)";
    bomb.y = -1;
  }
  
  void add_bomb() {
    // find an open slot.
    for (Bomb bomb in _bombs) {
      if (bomb.y < 0) {
        bomb
          ..x = _rng.nextInt(_board_width)
          ..y = 80
          .._bomb.style.transform = "translate(${bomb.x}px,10px) translateZ(0)";
        
        _bomber.style.transform = "translateX(${bomb.x}px) translateZ(0)";
        break;
      }
    }    
  }

  
  void process_finger(TouchEvent event) {
    event.preventDefault();
    _player_pos = event.touches[0].page.x-(_bucket_width*2);
    _player1.style.transform = "translateX(${_player_pos}px) translateZ(0)";
  }
  
  void process_mouse(MouseEvent event) {
    event.preventDefault();
    _player_pos = event.clientX - (_bucket_width*2);
    _player1.style.transform = "translateX(${_player_pos}px) translateZ(0)";
  }

  void run() {
    _score = 0;
    changeLevel(1);
    window.animationFrame.then(gameLoop);
  }
  
}

void main() {
  print("MAIN");
  game = new KaboomGame();
  game.run();
}

