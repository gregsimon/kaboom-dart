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
  int _board_width = 0;
  int _player_pos = 0;
  int _game_board_height;
  int _score;
  List _bombs;            // bombs for this level.
  double _bomb_speed;      // rate at whicht he bombs fall
  int _level;             // current level [1..]
  
  KaboomGame() {
    print("KABOOM");
    _game_board = querySelector('#board');
    _player1 = querySelector('#player1');
    _bomber = querySelector('#bomber');
    
    _player1.style.visibility = 'visible';
    _bomber.style.visibility = 'visible';
    
    _board_width = _game_board.offsetWidth;
    _game_board_height = _game_board.offsetHeight;
    print("width=${_board_width} _game_board_height=${_game_board_height}");
    
    // the bottom logo bar is also the touch controller surface
    querySelector('#logo-wrapper').onTouchStart.listen(process_finger);
    querySelector('#logo-wrapper').onTouchMove.listen(process_finger);
    querySelector('#logo-wrapper').onMouseMove.listen(process_mouse);
  }
  
  void changeLevel(int levelNum) {
    _level = levelNum;
    
    // This is how many maximum bombs we'll drop on 
    // this level. TODO : we should be recycling these DOM elements
    _bombs = new List(levelNum * 4);
    for (int i=0; i<_bombs.length; i++)
      _bombs[i] = new Bomb();
    
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
        
        bomb._bomb.style.transform = "translate(${bomb.x}px,${bomb.y}px)";
       
        // has bucket gone off the bottom?
        if (bomb.y >= _game_board_height) {
          // TODO level over -- do explosion sequence
          remove_bomb(bomb);
          numLive--;
        }
       
        // Do collision detection with bucket.
        if ( (bomb.y >= (_game_board_height-50)) && (bomb.x - _player_pos).abs() < 40) {
          // TODO bucket has cought a bomb!
          _score ++;
          print("score="+_score.toString());
          // TODO : update the score UI
          
          remove_bomb(bomb);
          numLive--;
        }
        
      } // bomb is live
      
    } // foreach(bombs)
    
    
    // Should we add another bomb falling?
    if (numLive < 4) {
      add_bomb();
    }
    
    window.animationFrame.then(gameLoop);
  }
    
  void remove_bomb(Bomb bomb) {
    DivElement e = bomb._bomb;
    bomb._bomb = null;
    bomb.y = -1;
    
    _game_board.children.remove(e);    
  }
  
  void add_bomb() {
    //print("adding bomb");
    Bomb newBomb;
    // find an open slot.
    for (Bomb bomb in _bombs) {
      if (bomb.y < 0) {
        newBomb = bomb;
        break;
      }
    }
    
    Random r = new Random();
    
    // add bomb
    newBomb
      .._bomb = new DivElement()
      ..x = r.nextInt(_board_width)
      ..y = 80
      .._bomb.className = 'bomb'
      .._bomb.style.transform = 'translate(10px,'+newBomb.x.toString()+'px)';
    _game_board.children.add(newBomb._bomb);
    _bomber.style.transform = "transformX("+newBomb.x.toString()+"px)";
  }

  
  void process_finger(TouchEvent event) {
    event.preventDefault();
    _player_pos = event.touches[0].page.x;
    _player1.style.transform = "translateX(${_player_pos}px)";
  }
  
  void process_mouse(MouseEvent event) {
    event.preventDefault();
    _player_pos = event.clientX;
    _player1.style.transform = "translateX(${_player_pos}px)";
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

