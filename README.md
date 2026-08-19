# Tải về local

```bash
wget https://raw.githubusercontent.com/yinghaoz1/tmdb-movie-dataset-analysis/master/tmdb-movies.csv
```

# Data heading

Với những task xử lý dữ liệu, đầu tiên em sẽ cần phải biết rõ về heading của file để xem data trong file này là gì

```bash
head -1 project1_data.csv | tr ',' '\n' | nl > data_heading.txt
```

Kết quả trả về:

```
     1	id
     2	imdb_id
     3	popularity
     4	budget
     5	revenue
     6	original_title
     7	cast
     8	homepage
     9	director
    10	tagline
    11	keywords
    12	overview
    13	runtime
    14	genres
    15	production_companies
    16	release_date
    17	vote_count
    18	vote_average
    19	release_year
    20	budget_adj
    21	revenue_adj
```

---

# Task 1

Sắp xếp các bộ phim theo ngày phát hành giảm dần rồi lưu ra một file mới:

- **Ngày phát hành** là `release_date` , tương đương cột `16` .

Task này em đã thử khá nhiều cách, xoay quanh `awk` , `perl` nhưng config regrex thuần khá khó, em cũng đã research để xài thử `-MText::ParseWords`  nhưng kết quả trả về sẽ luôn có lỗi. Vì vậy em đã tìm kiếm xem có command line tools nào có thể sử dụng không thì tìm được `csvkit` .

```bash
csvsort -c release_date -r project1_data.csv > task1.csv
```

Kiểm tra bằng cách `cut` riêng cột release_date ra và `look` nó, trong đoạn command line dưới em để 10 hàng cho dễ nhìn, đã check với không giới hạn và em thấy ổn:

```bash
csvcut -c release_date task1.csv | head -10 | csvlook

| release_date |
| ------------ |
|   2015-12-31 |
|   2015-12-31 |
|   2015-12-30 |
|   2015-12-27 |
|   2015-12-26 |
|   2015-12-25 |
|   2015-12-25 |
|   2015-12-25 |
|   2015-12-25 |
```

Tổng kết:

- **Input**: project1_data.csv
- **Output**: task1.csv

---

# Task 2

Lọc ra các bộ phim có đánh giá trung bình trên 7.5 rồi lưu ra một file mới:

- Đánh giá trung bình nghĩa là nó sẽ là `vote_average` , tương ứng cột `18` .

Với bài này thì em nhớ lúc đọc tài liệu về text processing có đọc được về `grep` để tìm dòng khớp với pattern, nên em đã search thử thằng `csvkit` có không thì lòi ra được `csvgrep` . Nhưng việc sử dụng `csvgrep` sẽ yêu cầu viết regrex, mà regrex cho trường hợp so sánh số khá phức tạp nên em đã đọc documentation của `csvkit` để tìm xem có lệnh nào khác khả quan hơn không, lúc này thì em có để ý tới `csvsql` và đi kèm với `--query QUERIES` .

```bash
csvsql --query 'select * from project1_data where vote_average > 7.5' project1_data.csv > task2.csv
```

Kiểm tra:

```bash
csvcut -c vote_average task2.csv | head -10 | csvlook

| vote_average |
| ------------ |
|          7,6 |
|          8,0 |
|          7,6 |
|          7,6 |
|          7,8 |
|          8,0 |
|          7,7 |
|          7,7 |
|          7,7 |
```

Tổng kết:

- **Input**: project1_data.csv
- **Output**: task2.csv

---

# Task 3

Tìm ra phim nào có doanh thu cao nhất và doanh thu thấp nhất:

- Doanh thu là `revenue` là cột thứ `5` .

Ban đầu khi đọc đề em có nghĩ tới `sort` xong rồi lấy `head` và `tail` . Với bài này đầu tiên em sẽ thử với cách sử dụng `csvkit` sau đó mới tới `linux command` vì revenue nằm ở trước cột `overview` nên khả năng lỗi `,` nó sẽ ít hơn.

```bash
csvsort -c revenue -r project1_data.csv | csvcut -c original_title,revenue | head -n 2 | csvlook
| original_title |       revenue |
| -------------- | ------------- |
| Avatar         | 2.781.505.847 |

csvsort -c revenue -r project1_data.csv | csvcut -c original_title,revenue | tail -1 | csvlook
| Manos: The Hands of Fate | 0 |
| ------------------------ | - |

csvsort -c revenue -r project1_data.csv | csvcut -c original_title,revenue | tail -10 | csvlook
| The Ugly Dachshund                               |     0 |
| ------------------------------------------------ | ----- |
| Nevada Smith                                     | False |
| The Russians Are Coming, The Russians Are Coming | False |
| Seconds                                          | False |
| Carry On Screaming!                              | False |
| The Endless Summer                               | False |
| Grand Prix                                       | False |
| Beregis Avtomobilya                              | False |
| What's Up, Tiger Lily?                           | False |
| Manos: The Hands of Fate                         | False |
```

`False` trong trường hợp này tương ứng với `0` , việc sử dụng `csvsort` cho thấy kết quả có khá nhiều phim có cùng doanh thu thấp nhất tương ứng với `0` nên em muốn xài một cách khác để coi rõ ràng hơn.

```bash
csvsql --query 'select original_title, revenue from project1_data order by revenue desc limit 1' project1_data.csv | csvlook
| original_title |       revenue |
| -------------- | ------------- |
| Avatar         | 2.781.505.847 |

csvsql --query 'select original_title, revenue from project1_data order by revenue asc, original_title asc limit 10' project1_data.csv | csvlook
| original_title                     | revenue |
| ---------------------------------- | ------- |
| $5 a Day                           |       0 |
| $9.99                              |       0 |
| (T)Raumschiff Surprise - Periode 1 |       0 |
| 1                                  |       0 |
| 1                                  |       0 |
| 10                                 |       0 |
| 10 Rillington Place                |       0 |
| 10.000 KM                          |       0 |
| 10.5: Apocalypse                   |       0 |
| 100 Bloody Acres                   |       0 |

csvsql --query 'select original_title, revenue from project1_data order by revenue asc, original_title desc limit 10' project1_data.csv | csvlook
| original_title       | revenue |
| -------------------- | ------- |
| í•˜ìš¸ë§             |       0 |
| í˜•ì‚¬ Duelist       |       0 |
| í¬í™” ì†ìœ¼ë¡œ       |       0 |
| ì‹ ì˜ í•œ ìˆ˜        |       0 |
| ì•„ê¸°ì™€ ë‚˜        |       0 |
| ì˜í˜•ì œ             |       0 |
| ìž‘ì—…ì˜ ì •ì„       |       0 |
| ìºì¹˜ë¯¸             |       0 |
| ì§‘ìœ¼ë¡œ ê°€ëŠ” ê¸¸ |       0 |
| ì§íŒ¨                |       0 |
```

Cách làm với `linux command` :

```bash
sort -t',' -k5 -nr project1_data.csv | cut -d',' -f6,5 | head -1
2781505847,Avatar

sort -t',' -k5 -n project1_data.csv | cut -d',' -f6,5 | head -10
0,Young Einstein
0,Mona Lisa
0,The Giant Mechanical Man
0,Desperation
0,Behind Enemy Lines II: Axis of Evil
0,See No Evil
0,Nazis at the Center of the Earth
0,An American Haunting
0,Brother Bear 2
0,Outpost: Black Sun

```

Tổng kết

- **Input**: project1_data.csv
- **Output**:
    - `Avatar` với doanh thu là `2.781.505.847`
    - Rất nhiều phim với doanh thu là `0`

---

# Task 4

Tính tổng doanh thu tất cả các bộ phim, vời bài này thì em nghĩ đơn giản là chỉ cần tính tổng của `revenue` trong bảng chính thôi. Hoặc là duyệt từng dòng và cộng dồn doanh thu vào một biến cố định bằng cách sử dụng `awk` .

```bash
csvsql --query 'select sum(revenue) as total_revenue from project1_data' project1_data.csv
total_revenue
432720192875.0
```

```bash
awk -F',' 'NR>1 {sum += $5} END {print sum}' project1_data.csv
4,3272e+11
```

Tổng kết:

- **Input**: project1_data.csv
- **Output**: tổng doanh thu là $4.3272 \times 10^{11}$ hoặc 432.720.192.875

---

# Task 5

Top 10 bộ phim đem về lợi nhuận cao nhất:

- Lợi nhuận sẽ được tính bằng cách lấy `revenue - budget` , tương ứng là lấy cột `5` trừ đi cho cột `4` . Rồi sau đó sẽ `sort` và lấy `head -10` . Bài này có 1 chỗ em phải hỏi AI để biết lý do sai, vì nếu `sort` theo numeric thì thằng `Avatar` sẽ không được tính vào kết quả đầu ra - `sort -nr` , lý do là bởi vì `awk` có giới hạn số nguyên `32-bit` là `2.14 tỷ`, nên kết quả thằng `Avatar` sẽ tự trở thành `2.5e+09` dẫn tới việc thằng sort nó bỏ qua vì nó tính Avatar là `2.5` .

```bash
awk -F',' 'NR>1 {profit = $5 - $4; print profit, $6}' project1_data.csv | sort -gr | head -10
2,54451e+09 Avatar
1868178225 Star Wars: The Force Awakens
1645034188 Titanic
1363528810 Jurassic World
1316249360 Furious 7
1299557910 The Avengers
1202817822 Harry Potter and the Deathly Hallows: Part 2
1125035767 Avengers: Age of Ultron
1124219009 Frozen
1084279658 The Net
```

```bash
csvsql --query 'with bang_loi_nhuan as (select (revenue - budget) as loi_nhuan, original_title from project1_data) select loi_nhuan, original_title from bang_loi_nhuan order by loi_nhuan desc limit 10' project1_data.csv
loi_nhuan,original_title
2544505847.0,Avatar
1868178225.0,Star Wars: The Force Awakens
1645034188.0,Titanic
1363528810.0,Jurassic World
1316249360.0,Furious 7
1299557910.0,The Avengers
1202817822.0,Harry Potter and the Deathly Hallows: Part 2
1125035767.0,Avengers: Age of Ultron
1124219009.0,Frozen
1084279658.0,The Net
```

Tổng kết:

- **Input**: project1_data.csv
- **Output**:
    - Avatar
    - Star Wars: The Force Awakens
    - Titanic
    - Jurassic World
    - Furious 7
    - The Avengers
    - Harry Potter and the Deathly Hallows: Part 2
    - Avengers: Age of Ultron
    - Frozen
    - The Net

---

# Task 6

Đạo diễn nào có nhiều bộ phim nhất và diễn viên nào đóng nhiều phim nhất:

- Đạo diễn là `director` tương ứng là cột 9, diễn viên là `cast` tương ứng là cột 7

Em nhớ hồi đọc tài liệu có `uniq -c` để count, nên em nghĩ tới việc mình có thể `sort`, `uniq -c` và `sort -nr` . Vì bên diễn viên em thấy có sử dụng `|` để phân ra cho từng diễn viên nên để đề phòng 1 bộ phim có nhiều đạo diễn em cũng sẽ thay đổi dấu `|` thành `\n` để phân ra.

```bash
csvcut -c director project1_data.csv | tr '|' '\n' | sort | uniq -c | sort -nr | head -10
46 Woody Allen
44 ""
34 Clint Eastwood
31 Martin Scorsese
30 Steven Spielberg
23 Steven Soderbergh
23 Ridley Scott
22 Ron Howard
21 Joel Schumacher
20 Tim Burton

csvcut -c cast project1_data.csv | tr '|' '\n' | sort | uniq -c | sort -nr | head -10
76 ""
72 Robert De Niro
69 Samuel L. Jackson
62 Bruce Willis
61 Nicolas Cage
53 Michael Caine
51 Robin Williams
50 John Cusack
49 Morgan Freeman
49 John Goodman
```

Tổng kết:

- **Input**: project1_data.csv
- **Output**:
    - Đạo diễn có nhiều bộ phim nhất là `Woody Allen`
    - Diễn viên đóng nhiều bộ phim nhất là `Robert De Niro`

---

# Task 7

Thống kê số lượng phim theo các thể loại:

- Thể loại là `genres`, tương ứng là cột `14` .

Với bài này em thấy nó khá giống `task 6` .

```bash
csvcut -c genres project1_data.csv | tr '|' '\n' | sort | uniq -c | sort -n
1 genres
23 ""
165 Western
167 TV Movie
188 Foreign
270 War
334 History
408 Music
520 Documentary
699 Animation
810 Mystery
916 Fantasy
1230 Science Fiction
1231 Family
1355 Crime
1471 Adventure
1637 Horror
1712 Romance
2385 Action
2908 Thriller
3793 Comedy
4761 Drama
```

Tổng kết:

- **Input**: project1_data.csv
- **Output**:

```
165 Western
167 TV Movie
188 Foreign
270 War
334 History
408 Music
520 Documentary
699 Animation
810 Mystery
916 Fantasy
1230 Science Fiction
1231 Family
1355 Crime
1471 Adventure
1637 Horror
1712 Romance
2385 Action
2908 Thriller
3793 Comedy
4761 Drama
```

---

# Idea

Em có nghĩ ra vài idea để phân tích dữ liệu:

- Xem coi mức độ hợp tác giữa đạo diễn với diễn viên ở mức nào, giống như tìm xem đạo diễn A hợp tác với diễn viên B bao nhiêu lần, tần suất làm việc chung tiếp sau lần đầu là bao nhiêu
- Mức độ bom tấn tính toán trên revenue do diễn viên đem lại là bao nhiêu, tính toán xem mức độ nhận diện của diễn viên A ảnh hưởng tới bộ phim
- Cái budget adj với revenue adj hơi rườm rà nhưng có thể dùng nó đi chung với release date để tính toán xem ở thời x thì mức độ xem phim của mọi người như thế nào, khác gì so với thời y
