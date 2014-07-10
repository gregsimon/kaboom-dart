import 'dart:html';

KaboomGame game;

class Bomb {
  Bomb() {
    x = -1;
    y = -1;
  }
  
  int x, y;
  DivElement _bomb;
}

class KaboomGame {
  DivElement _game_board;
  DivElement _bomber;
  DivElement _player1;
  int _board_width = 0;
  int _player_pos = 0;
  List _bombs;            // bombs for this level.
  double _bomb_speed;      // rate at whicht he bombs fall
  int _level;             // current level [1..]
  
  KaboomGame() {
    _game_board = querySelector('#board');
    _player1 = querySelector('#player1');
    _bomber = querySelector('#bomber');
    
    _player1.style.visibility = 'visible';
    _bomber.style.visibility = 'visible';
    
    _board_width = _game_board.offsetWidth;
    window.console.log("width=" + _board_width.toString());
    
    // the bottom logo bar is also the touch controller surface
    querySelector('#logo-wrapper').onTouchStart.listen(processFinger);
    querySelector('#logo-wrapper').onTouchMove.listen(processFinger);
   
  }
  
  void changeLevel(int levelNum) {
    _level = levelNum;
    
    // This is how many maximum bombs we'll drop on 
    // this level. TODO : we should be recycling this...
    _bombs = new List(levelNum * 4);
    for (int i=0; i<_bombs.length; i++)
      _bombs[i] = new Bomb();
    
    _bomb_speed = levelNum * 1.5;
  }
  
  void processFinger(TouchEvent event) {
    event.preventDefault();
    _player_pos = event.touches[0].page.x;
    _player1.style.transform = "translateX("+ _player_pos.toString() +"px)";
  }

  void run() {
    changeLevel(1);
  }
  
}



void main() {
  game = new KaboomGame();
  game.run();
}

