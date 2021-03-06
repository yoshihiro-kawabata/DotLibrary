require 'securerandom'

#Authority
Authority.create!(
  level: "1",
  name: "司書"
   )

Authority.create!(
  level: "2",
  name: "書店"
   )
  
Authority.create!(
  level: "3",
  name: "個人提供者"
   )
    
#master_user
User.create!(
    number: "9000",
    password: "master",
    password_confirmation: "master"
     )

Library.create!(
      name: "master図書館",
      sub_number: "9000",
      email: "master_libra@master.com",
      phone: "999-9999-999",
      address: "東京都東京区東京1-1-1",
      user_id: 1
    )

authorityA = Authority.find(1)
UsersAuthority.create!(user_id:1, authority_id:authorityA.id)

User.create!(
  number: "8000",
  password: "master",
  password_confirmation: "master"
   )

Store.create!(
    name: "master書店",
    sub_number: "8000",
    phone: "000-0000-000",
    fax: "0000-0000-00",
    manager: "たにた",
    email: "master_store@master.com",
    address: "埼玉都埼玉区埼玉1-1-1",
    user_id: 2
  )

authorityA = Authority.find(2)
UsersAuthority.create!(user_id:2, authority_id:authorityA.id)

5.times do |n|
  Message.create!(
    content: "テストメッセージ#{n + 1}です",
    create_name: "master書店",
    create_id: 2,
    user_name: "master図書館",
    user_id: 1
)
end

User.create!(
  number: "7000",
  password: "master",
  password_confirmation: "master"
   )

Provider.create!(
    name: "master提供者",
    sub_number: "7000",
    email: "master_provider@master.com",
    phone: "777-7777-777",
    address: "京都府京都区京1-1-1",
    user_id: 3
  )

authorityA = Authority.find(3)
UsersAuthority.create!(user_id:3, authority_id:authorityA.id)

5.times do |n|
  Message.create!(
    content: "テストメッセージ#{n + 6}です",
    create_name: "master提供者",
    create_id: 3,
    user_name: "master図書館",
    user_id: 1
)
end


#test_user
12.times do |n|
  User.create!(
    number: "#{n + 4}",
    password: "#{(n + 4) * 111111}",
    password_confirmation: "#{(n + 4) * 111111}"
        )
end

authorityA = Authority.find(1)

4.times do |n|
  Library.create!(
    name: "テスト図書館#{n}",
    sub_number: "#{(n + 4) * 111111}",
    email: "libra#{n + 4}@libra.com",
    phone: "#{n + 4}-#{n + 4}-#{n + 4}",
    address: "#{n + 4}",
    user_id: "#{n + 4}"
  )
  UsersAuthority.create!(user_id:"#{n + 4}", authority_id:authorityA.id)
end

authorityA = Authority.find(2)

4.times do |n|
  Store.create!(
    name: "テスト書店#{n}",
    sub_number: "#{(n + 8) * 111111}",
    phone: "#{n + 12}-#{n + 12}-#{n + 12}",
    fax: "#{n + 8}-#{n + 8}-#{n + 8}",
    manager: "テスト担当#{n}",
    email: "store#{n + 8}@store.com",
    address: "#{n + 8}",
    user_id: "#{n + 8}"
  )
  UsersAuthority.create!(user_id:"#{n + 8}", authority_id:authorityA.id)
  Message.create!(
    content: "テストメッセージ#{n + 1}です",
    create_name: "テスト書店#{n}",
    create_id: "#{n + 8}",
    user_name: "テスト図書館#{n}",
    user_id: "#{n + 4}"
  )  
end

authorityA = Authority.find(3)

4.times do |n|
  Provider.create!(
    name: "テスト提供者#{n}",
    sub_number: "#{(n + 12) * 111111}",
    email: "provider#{n + 12}@provider.com",
    phone: "#{n + 12}-#{n + 12}-#{n + 12}",
    address: "#{n + 12}",
    user_id: "#{n + 12}"
  )
  UsersAuthority.create!(user_id:"#{n + 12}", authority_id:authorityA.id)
  Message.create!(
    content: "テストメッセージ#{n + 1}です",
    create_name: "テスト提供者#{n}",
    create_id: "#{n + 12}",
    user_name: "テスト図書館#{n}",
    user_id: "#{n + 4}"
  )  
end

#example_book
book = Book.create!(      
  id: 0,
  name: "ほね",
  number: 0,
  keyword1:"堀内誠一",
  keyword2:"かがく絵本・図鑑",
  keyword3:"ページ数： 24ページ",
  keyword4:"かがくのとも絵本"
 )
 book.images.attach(io: File.open(Rails.root.join('app/assets/images/hone.jpg')),
 filename: 'hone.jpg')

BooksStore.create!(
  store_id: 1, 
  book_id:0 , 
  quantity:10,
  price: 1200,
  limit: "2022年7月下旬"
)

#example_book
book = Book.create!(      
  name: "ほね",
  number: 1,
  keyword1:"堀内誠一",
  keyword2:"かがく絵本・図鑑",
  keyword3:"ページ数： 24ページ",
  keyword4:"かがくのとも絵本"
 )
 book.images.attach(io: File.open(Rails.root.join('app/assets/images/hone.jpg')),
 filename: 'hone.jpg')

 BooksProvider.create!(
  provider_id: 1, 
  book_id:1, 
  quantity:1,
  hand_flg: true
)

5.times do |n|
  book = Book.create!(      
    name: "test#{n + 1}",
    number: n + 1,
    keyword1:"キーワード#{n + 1}"
   )
   book.images.attach(io: File.open(Rails.root.join("app/assets/images/test#{n + 1}.jpg")),
   filename: "test#{n + 1}.jpg")
  
  BooksStore.create!(
    store_id: n + 1, 
    book_id: n + 2, 
    quantity:n + 1,
    price: (n + 1) * 500,
    limit: "2023年#{n + 1}月予定"
  )
  end

  5.times do |n|
    book = Book.create!(      
      name: "test#{n + 6}",
      number: n + 6,
      keyword1:"キーワード#{n + 6}"
     )
     book.images.attach(io: File.open(Rails.root.join("app/assets/images/test#{n + 6}.jpg")),
     filename: "test#{n + 6}.jpg")
    
     BooksProvider.create!(
      provider_id: n + 1, 
      book_id: n + 7, 
      quantity:n + 1,
      hand_flg: false
    )
  end

  4.times do |n|
    book = Book.create!(      
      name: "test#{n + 4}",
      number: n + 12,
      keyword1:"キーワード#{n + 4}"
     )
     book.images.attach(io: File.open(Rails.root.join("app/assets/images/test#{n + 4}.jpg")),
     filename: "test#{n + 4}.jpg")
    
    BooksLibrary.create!(
      library_id: n + 2, 
      book_id: n + 12, 
      quantity:n + 3,
      remark: "譲渡可能"
    )
    end

  4.times do |n|
    book = Book.create!(      
      name: "test#{n + 2}",
      number: n + 16,
      keyword1:"著者#{n + 1}",
      keyword2:"出版社#{n + 5}"
     )
    book.images.attach(io: File.open(Rails.root.join("app/assets/images/test#{n + 2}.jpg")),
    filename: "test#{n + 2}.jpg")
      
    BooksLibrary.create!(
      library_id: 1, 
      book_id: n + 16, 
      quantity:n + 3,
      remark: "貸出可能"
    )
    end
  
  #master_order
Order.create!(
  id: 0,
  title: "masterorder",
  user_id: 2,
  user_name: "master書店",
  receive_user_id: 1,
  receive_user_name: "master図書館",
  number: 0,
  complete_flg: false,
  ord_limit: "No",
  condition: "No",
  price: 0
  )

  4.times do |n|
  Order.create!(
    title: "【完了】master図書館_test",
    user_id: "1",
    user_name: "master図書館",
    receive_user_id: "#{n + 8}",
    receive_user_name: "テスト書店#{n}",
    number: 13,
    complete_flg: true,
    ord_limit: "テスト日末日",
    condition: "月末払い",
    price: (n + 2) * 3000,
    created_at: DateTime.current.ago(1.days),
    updated_at: DateTime.current
  )
  end

  4.times do |n|
  Comment.create!(
    user_name: "master図書館",
    content: "テストコメント#{n}です",
    order_id: "#{n + 1}",
    user_id: 1
  )
  end
  
  4.times do |n|
    Comment.create!(
      user_name: "テスト書店#{n}",
      content: "テストコメント#{n + 4}です",
      order_id: "#{n + 1}",
      user_id: "#{n + 8}"
    )
  end

  4.times do |n|
    Detail.create!(
      name: "test#{n + 2}",
      quantity: "#{n + 2}",
      price: 500,
      remark: "---",
      order_id: "#{n + 1}"
    )

    Detail.create!(
      name: "送料",
      quantity: 0,
      price: (n + 2) * 500,
      remark: "送料",
      order_id: "#{n + 1}"
    )

    Detail.create!(
      name: "装備費",
      quantity: 0,
      price: (n + 2) * 800,
      remark: "装備費用",
      order_id: "#{n + 1}"
    )

    Detail.create!(
      name: "その他",
      quantity: 0,
      price: (n + 2) * 1200,
      remark: "テストデータ#{n}",
      order_id: "#{n + 1}"
    )
  end

10.times do |n|
  book = Book.create!(      
    name: "test#{n + 21}",
    number: n + 21,
    keyword1:"キーワード#{n + 21}"
   )
   book.images.attach(io: File.open(Rails.root.join("app/assets/images/test#{n + 1}.jpg")),
   filename: "test#{n + 1}.jpg")

  BooksStore.create!(
    store_id: 1, 
    book_id: n + 20, 
    quantity:9999999,
    price: 9999999,
    limit: "2023年#{n + 1}月予定"
  )
  end
