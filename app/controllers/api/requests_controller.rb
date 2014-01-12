# coding: utf-8
require_relative '../../../lib/workers/http_tool.rb'
require_relative '../../../lib/workers/sreality.rb'

class API::RequestsController < ApplicationController
  respond_to :json
  skip_before_action :verify_authenticity_token
  #before_action :set_request, only: [:show, :edit, :update, :destroy]

  def get_url_info
    # test this url, it it is valid SReality url
    errors = []
    url = params[:url]
    http_tool = HttpTool.new
    sreality = Sreality.new http_tool
    if url !~ URI::regexp
      errors << "Nesprávná url adresa, zkontrolujte, zda-li začíná znaky \"http://\""
    elsif !sreality.is_url_valid?(url)
      errors << "Nesprávná url - můžete zadat pouze adresu vedoucí na server Sreality.cz,
          např. \"http://www.sreality.cz/search?category_type_cb=1&category_main_cb=1...\""
    else
      begin
        page_info = sreality.get_page_summary(url)
        unless page_info
          errors << "Bohužel náš systém nebyl schopen tuto adresu zpracovat.
Chyba bude zřejmě na naší straně a nejsme schopni ji vyřešit ihned. Ale uložili jsme si ji a náš
team se jí bude co nejdříve zabývat."
        else
          if page_info['total'].to_i > 500
            errors << "Počet inzerátů ke sledování je příliš velký ("+page_info['total'].to_s()+"),
pokuste se více specifikovat oblast nebo cenu."
          else
            return respond_with({total: page_info['total']})
          end
        end
      rescue
        errors << $!
      end
    end
    return respond_with({errors: errors}, status: 400)
  end

  # GET /requests.json
  def index
    @requests = Request.where('token=?', params['token'])
    return respond_with(@requests)
  end

  # GET /requests/1
  # GET /requests/1.json
  #def show
  #  #@request = Request.find_by_token params['token']
  #  @request = Request.new
  #  respond_with @request
  #end

  # GET /requests/new
  def new
    #@request = Request.new
  end

  # GET /requests/1/edit
  def edit
  end

  # POST /requests
  # POST /requests.json
  def create
    @request = Request.new(request_params)
    @request.save
    RequestNotifier.NewRequestInfo(@request).deliver
    respond_with(@request, location: nil)
  end

  # PATCH/PUT /requests/1
  # PATCH/PUT /requests/1.json
  def update
    #respond_to do |format|
    #  if @request.update(request_params)
    #    format.html { redirect_to @request, notice: 'Request was successfully updated.' }
    #    format.json { head :no_content }
    #  else
    #    format.html { render action: 'edit' }
    #    format.json { render json: @request.errors, status: :unprocessable_entity }
    #  end
    #end
  end

  # DELETE /requests/1
  # DELETE /requests/1.json
  def destroy
    @request = Request.find(params[:id])
    @request.destroy
    respond_with()
  end

  private
  def request_params
    params.require(:request).permit(:name, :url, :email)
  end

end
