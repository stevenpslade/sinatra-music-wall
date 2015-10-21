# shareable methods
helpers do

  def logged_in?
    !!current_user
  end

  def current_user
    if cookies[:user_id]
      User.find(cookies[:user_id])
    end
  end

  def getCount(song, type)
    song.likes.where(like_type: type).count
  end

  def not_voted?(user_id, song_id)
    !(Like.where("user_id = ? AND song_id = ?", user_id, song_id).any?)
  end

end

# Homepage (Root path)
get '/' do
  erb :index
end

get '/login/signup' do
  @user = User.new
  erb :'login/signup'
end

post '/login/signup' do
  @user = User.new(
    first_name: params[:first_name],
    last_name: params[:last_name],
    email: params[:email],
    password: params[:password]
    )
  if @user.save
    cookies[:user_id] = @user.id
    redirect '/songs'
  else
    @error_messages = ['Invalid email or password']
    erb :'login/signup'
  end
end

get '/login/login' do
  erb :'login/login'
end

get '/login/logout' do
  cookies.delete :user_id
  redirect "login/login"
end

# set cookies to create user session?
# if you use cookies make sure they're encrypted
# enable/set for sessions for encryptions
post '/login/login' do
  @user = User.find_by(email: params[:email], password: params[:password])
  if @user
    cookies[:user_id] = @user.id
    redirect '/songs'
  else
    @error_messages = ['Invalid email or password']
    erb :'login/login'
  end
end

get '/songs' do
  @songs = Song.find_by_sql("SELECT songs.*, COUNT(likes.song_id) AS number FROM songs LEFT JOIN likes ON songs.id = likes.song_id GROUP BY songs.id ORDER BY number DESC")
  erb :'songs/index'
end

get '/songs/new' do
  @song = Song.new
  erb :'songs/new'
end

get '/songs/random' do
  random_num = rand(Song.count)
  @rand_song = Song.offset(random_num).first
  redirect "/songs/#{@rand_song.id}"
end

get '/songs/:id' do
  @song = Song.find params[:id]
  @other_songs = Song.where("author = ? AND id != ? ", @song.author, @song.id)
  erb :'songs/show'
end

post '/songs' do
  @song = Song.new(
    song_title: params[:song_title],
    author: params[:author],
    img_link: params[:img_link],
    url:  params[:url],
    user_id: cookies[:user_id]
  )
  if @song.save
    redirect '/songs'
  else
    erb :'songs/new'
  end
end

get '/like/:id/:type' do
  song = Song.find params[:id]
    if logged_in?
      if not_voted?(cookies[:user_id], song.id)
        @like = Like.create(
          user_id: cookies[:user_id],
          song_id: song.id,
          like_type: params[:type]
          )
      end
    end
  redirect "/songs"
end