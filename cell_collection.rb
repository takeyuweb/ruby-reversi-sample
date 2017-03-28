# frozen_string_literal: true
require_relative './cell'

# セル
class CellCollection
  include Enumerable
  attr_reader :size

  def initialize(size)
    @size = size
    @cells = Array.new(size).map do
      Array.new(size) { Cell.new }
    end
  end

  # (x, y) のセルを取得
  # 範囲外なら RangeError
  def get(x:, y:)
    key_range = 0 .. (size-1)
    raise RangeError if !key_range.include?(x) || !key_range.include?(y)
    @cells[y][x]
  end

  def each
    @cells.each_with_index do |row, y|
      row.each_with_index do |_cell, x|
        yield(x, y)
      end
    end
  end

  def to_s
    lines = []
    lines << ' ' + @cells.size.times.map(&:to_s).join(' ')
    @cells.each_with_index do |rows, y|
      lines << y.to_s + rows.map(&:to_s).join
    end
    lines.join("\n")
  end
end