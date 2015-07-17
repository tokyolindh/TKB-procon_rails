# -*- coding: utf-8 -*-
class AnswersController < ApplicationController

  def index
    @student_id = params[:user_id]
    @lesson_id = params[:lesson_id]
    @question_id = params[:question_id]
    @question_diff_detail= Answer.where(:question_id => @question_id,:lesson_id=> @lesson_id,:student_id=> @student_id )
    @dead_date_question = LessonQuestion.find_by(lesson_id: @lesson_id  , question_id: @question_id )

    @file_name  = Answer.where(:question_id => @question_id,:lesson_id=> @lesson_id,:student_id=> @student_id ).last.file_name
    @path_directory ='./uploads/'+ @student_id.to_s +  '/' + @lesson_id.to_s + '/' + @question_id.to_s + '/'

    @path = @path_directory + @file_name
    @content = File.read(@path)


  end

  # post '/answers'
  # @param [Binary] upload_file アップロードファイル
  # @param [language] language 選択言語
  # @param [Fixnum] lesson_id
  # @param [Fixnum] id Questionのid
  def create
    file = params[:upload_file]
    unless file.nil?
      extention = Answer::EXT[params[:language]]
      name = file.original_filename

      if !(extention == File.extname(name).downcase)
        flash[:alert] = '使用言語とファイル拡張子が一致しません。'
      elsif file.size > 10.megabyte
        flash[:alert] = 'ファイルサイズは10MBまでにしてください。'
      else
        path = Rails.root.join('uploads', current_user.id.to_s, params[:lesson_id], params[:id]).to_s
        FileUtils.mkdir_p(path) unless FileTest.exist?(path)

        old_file = Answer.where(:lesson_id => params[:lesson_id],
                               :student_id => current_user.id,
                               :question_id => params[:id]).last
        /\d+/ =~ old_file.file_name unless old_file.nil?
        version = $&.to_i
        next_version = (version + 1).to_s
        next_name = "version" + next_version + extention

        File.open(path + "/" + next_name, 'wb') do |f|
          f.write(file.read)
        end
        answer = Answer.new(:language => params[:language],
                            :question_id => params[:id],
                            :lesson_id => params[:lesson_id],
                            :file_name => next_name,
                            :result => 1,
                            :student_id => current_user.id)
        answer.save
        flash[:notice] = '回答を投稿しました。'
      end
    else
      flash[:alert] = 'ファイルが選択されていません。'
    end
    redirect_to :controller => 'questions', :action => 'show', :lesson_id => params[:lesson_id], :id => params[:id]
  end

  def select_version
    @select_item = params[:selected_file]
    @select_path = params[:selected_path]
    @newpath = @select_path.to_s + @select_item
  end

end
