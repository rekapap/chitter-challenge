feature 'Logging out' do
  scenario 'a user can login with a right username ans password' do
    User.create(name: 'John', username: 'john', email: 'john@example.com', password: 'password123')
    visit '/sessions/new'
    fill_in('username', with: 'john')
    fill_in('password', with: 'password123')
    click_button('Login')

    click_button('Logout')
    expect(page).not_to have_content "Welcome, John"
    expect(page).not_to have_content "You are logged in with this email: john@example.com"
    expect(page).to have_content "Chitter"
    expect(page).to have_content 'You have logged out.'
  end
end
