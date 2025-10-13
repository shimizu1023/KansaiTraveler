categories = %w[大阪府 京都府 兵庫県 奈良県 和歌山県 滋賀県 三重県]

categories.each do |name|
  Category.find_or_create_by!(name: name)
end
