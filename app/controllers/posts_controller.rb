class PostsController < ApplicationController

  def index
    #passing the params[:author_id] into any spot looking for author to make sure that, 
    # if we capture an author_id through a nested route, we keep track 
    # of it and assign the post to that author, then carrying this id 
    # with us for the next few steps, babysitting it through the server request/response cycle.
    if params[:author_id]
      @posts = Author.find(params[:author_id]).posts
    else
      @posts = Post.all
    end
  end

  def show
    if params[:author_id]
      @post = Author.find(params[:author_id]).posts.find(params[:id])
    else
      @post = Post.find(params[:id])
    end
  end

  def new
    #check for params[:author_id] and then for Author.exists? 
    #to see if the author is real. 

    #Why aren't we doing a find_by to author instance? 
    #Bc we don't need a whole author instance for Post.new; 
    #we just need the author_id. And we don't need to check against 
    #the posts of the author because we're just creating a new one. 
    #So we use exists? to quickly/efficiently check the database 
    if params[:author_id] && !Author.exists?(params[:author_id])
      redirect_to authors_path, alert: "Authors not found."
    else
      @post = Post.new(author_id: params[:author_id])
    end
  end

  def create
    @post = Post.new(post_params)
    @post.save
    redirect_to post_path(@post)
  end

  def update
    @post = Post.find(params[:id])
    @post.update(post_params)
    redirect_to post_path(@post)
  end

  def edit
    #full url entered: authors/author_id/posts/:id/edit OR /posts/:id/edit
    #check if user enters an author_id (ie any number) into browser as authors/:author_id
    if params[:author_id]
      #check if an author is found at the author_id entered into browser by user
      author = Author.find_by(id: params[:author_id])
      #if there is no author with that id
      if author.nil?
        #redirect to authors index page w/ error
        redirect_to authors_path, alert: "Author not found."
      else
        #else try to find a post that exists for that author 
        #with the post's id entered into browser at: authors/author_id/posts/:id ...
        #if there is not a post w/ that id, redirect to authors/author_id/posts
        #to show all the posts associated with that author and flash alert message
        @post = author.posts.find_by(id: params[:id])
        redirect_to author_posts_path(author), alert: "Post not found." if @post.nil?
      end
    #otherwise if the post with that id is found, follow the 
    #inherent edit path to edit that post /posts/:id/edit
    else
        @post = Post.find(params[:id])
    end
  end

  private

  def post_params
    params.require(:post).permit(:title, :description, :author_id)
  end
end
