# frozen_string_literal: true
require_relative './cell_collection'
require_relative './piece'

# 盤
class Board
  DEFAULT_SIZE = 8.freeze
  attr_reader :current_turn

  def initialize(size=DEFAULT_SIZE)
    @cell_collection = CellCollection.new(size)

    # 右上が黒になるように最初の石を置く
    p1 = ((size-1).to_f / 2).floor
    p2 = ((size-1).to_f / 2).ceil
    @cell_collection.get(x: p2, y: p1).piece = Piece.new(Piece::COLOR_DARK)
    @cell_collection.get(x: p1, y: p2).piece = Piece.new(Piece::COLOR_DARK)
    @cell_collection.get(x: p1, y: p1).piece = Piece.new(Piece::COLOR_LIGHT)
    @cell_collection.get(x: p2, y: p2).piece = Piece.new(Piece::COLOR_LIGHT)

    # 先攻は黒
    @current_turn = Piece::COLOR_DARK
  end

  def size
    @cell_collection.size
  end

=begin
盤の状態を表示
 0 1 2 3 4 5 6 7
0・・・・・・・・
1・・・・・・・・
2・・・・・・・・
3・・・○●・・・
4・・・●○・・・
5・・・・・・・・
6・・・・・・・・
7・・・・・・・・
=end
  def to_s
    @cell_collection.to_s
  end

  # 置ける場所を配列で返す
  # [[0, 0], [0, 2], [1, 3]]
  def candidate_positions
    @cell_collection.select do |x, y|
      candidate_position?(x: x, y: y)
    end
  end

  # (x, y) に石を置けるか？
  # まだ石がなく、かつ上下左右斜めのどこかで他の色の石を挟めれば真
  def candidate_position?(x:, y:)
    @cell_collection.get(x: x, y: y).blank? &&
        reversible_pieces(x: x, y: y).any?
  end

  # (x, y) に石を置く
  # 置けないセルの場合ArgumentError
  def put(x:, y:)
    raise ArgumentError unless candidate_position?(x: x, y: y)
    reversible_pieces(x: x, y: y).each(&:reverse!)
    @cell_collection.get(x: x, y: y).piece = Piece.new(current_turn)
    next_turn!
  end

  # ゲーム終了か？
  # 置く場所がなくなったらおわり
  def gameover?
    candidate_positions.empty?
  end

  # 勝者
  # 数の多い方が勝ち
  def winner
    return unless gameover?
    if dark_count > light_count
      :dark
    elsif dark_count < light_count
      :light
    else
      :draw
    end
  end

  # 黒の石の数
  def dark_count
    count_pieces(Piece::COLOR_DARK)
  end

  # 白の石の数
  def light_count
    count_pieces(Piece::COLOR_LIGHT)
  end

  private
  # 裏返し対象
  def reversible_pieces(x:, y:)
    upperside_pieces(x: x, y: y) |
        lowerside_pieces(x: x, y: y) |
        rightside_pieces(x: x, y: y) |
        leftside_pieces(x: x, y: y) |
        upperrightside_pieces(x: x, y: y) |
        lowerrightside_pieces(x: x, y: y) |
        upperleftside_pieces(x: x, y: y) |
        lowerleftside_pieces(x: x, y: y)
  end

  # 先頭から順にみていき 違う色が1つ以上続いた後、同じ色の石があるなら、一連の違う色の石を返す
  def select_reversible_pieces(pieces)
    other_color_index = pieces.find_index(next_turn)
    same_color_index = pieces.find_index(current_turn)
    other_color_found = !other_color_index.nil?
    other_color_count = same_color_index.to_i - other_color_index.to_i
    if other_color_found && other_color_count > 0
      pieces.slice(0, other_color_count)
    else
      []
    end
  end

  # (x, y)から上を順に見ていき続く石の配列を返す
  def upperside_pieces(x:, y:)
    select_reversible_pieces get_consecutive_pieces(start_x: x, start_y: y-1, dy: -1)
  end

  # (x, y)から下を順に見ていき続く石の配列を返す
  def lowerside_pieces(x:, y:)
    select_reversible_pieces get_consecutive_pieces(start_x: x, start_y: y+1, dy: 1)
  end

  # (x, y)から右を順に見ていき続く石の配列を返す
  def rightside_pieces(x:, y:)
    select_reversible_pieces get_consecutive_pieces(start_x: x+1, start_y: y, dx: 1)
  end

  # (x, y)から左を順に見ていき続く石の配列を返す
  def leftside_pieces(x:, y:)
    select_reversible_pieces get_consecutive_pieces(start_x: x-1, start_y: y, dx: -1)
  end

  def upperrightside_pieces(x:, y:)
    select_reversible_pieces get_consecutive_pieces(start_x: x+1, start_y: y-1, dx: 1, dy: -1)
  end

  def upperleftside_pieces(x:, y:)
    select_reversible_pieces get_consecutive_pieces(start_x: x-1, start_y: y-1, dx: -1, dy: -1)
  end

  def lowerrightside_pieces(x:, y:)
    select_reversible_pieces get_consecutive_pieces(start_x: x+1, start_y: y+1, dx: 1, dy: 1)
  end

  def lowerleftside_pieces(x:, y:)
    select_reversible_pieces get_consecutive_pieces(start_x: x-1, start_y: y+1, dx: -1, dy: 1)
  end

  def get_consecutive_pieces(start_x:, start_y:, dx: 0, dy: 0)
    pieces = []
    x = start_x
    y = start_y
    loop do
      cell = @cell_collection.get(x: x, y: y)
      break if cell.blank?
      pieces.push(cell.piece)
      x = x + dx
      y = y + dy
    end
    pieces
  rescue RangeError
    pieces
  end

  def count_pieces(color)
    @cell_collection.select { |x, y| @cell_collection.get(x: x, y: y) == color }.count
  end

  def next_turn
    @current_turn == Piece::COLOR_DARK ? Piece::COLOR_LIGHT : Piece::COLOR_DARK
  end

  def next_turn!
    @current_turn = next_turn
  end

end