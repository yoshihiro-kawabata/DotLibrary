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
    id: 0,
    name: "master",
    number: "9999",
    email: "master@master.com",
    password: "master",
    password_confirmation: "master",
    templete: Templete.find(0).id,
    group: Group.find(0).id,
    admin: true
     )


9.times do |n|
  User.create!(
    id: "#{n + 1}",
    name: "テスト太郎#{n + 1}",
    number: "#{(n + 1) * 1111}",
    email: "test#{n + 1}@test.com",
    password: "#{(n + 1) * 111111}",
    password_confirmation: "#{(n + 1) * 111111}",
    templete: templeteA.id,
    group: groupA.id,
    admin: false
    )
end

#master_user
User.create!(
    id: 10,
    name: "管理者花子0",
    number: "10000",
    email: "hanako@hanako.com",
    password: "hanako",
    password_confirmation: "hanako",
    templete: Templete.find(1).id,
    group: Group.find(0).id,
    admin: true
     )
    
#test_user

3.times do |n|

  User.create!(
    id: "#{n + 11}",
    name: "テスト太郎#{n + 11}",
    number: "#{(n + 11) * 1111}",
    email: "test#{n + 11}@test.com",
    password: "#{(n + 11) * 111111}",
    password_confirmation: "#{(n + 11) * 111111}",
    templete: templeteA.id,
    group: groupA.id,
    admin: false
    )
end
