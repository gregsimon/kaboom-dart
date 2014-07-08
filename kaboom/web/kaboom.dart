import 'dart:html';

KaboomGame game;

class KaboomGame {
  DivElement _gameBoard;
  
  KaboomGame() {
    _gameBoard = querySelector('#board');
  }

  void run() {
    // TODO
  }
  
}



void main() {
  game = new KaboomGame();
  game.run();
}

