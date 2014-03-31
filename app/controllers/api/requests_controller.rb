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
    page_info = do_url_check(url, errors)
    if page_info
      total = page_info['total']
      tarrif_parsed = Request.get_tarrif total
      return respond_with(
          {
              total: total,
              tarrif_parsed: tarrif_parsed,
              tarrif: tarrif_parsed.join('_')
          })
    else
      return respond_with({errors: errors}, status: 400)
    end
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
    errors = []
    @request = Request.new(request_params)
    page_info = do_url_check @request.url, errors
    do_email_check @request.email, errors
    if page_info && errors.length == 0
      begin
        total = page_info['total']
        @request.tarrif_parsed = @request.get_tarrif total
        @request.tarrif= @request.tarrif_parsed.join '_'
        if @request.tarrif_parsed[1] == 'FREE'
          @request.state = 'active'
        end
        @request.save! # save it second time to generate varsymbol
        @request.varsymbol = @request.generate_varsymbol @request.id
        @request.save!
        unless @request.tarrif_parsed[1] != 'FREE'
          # if this is not free tarrif, render SMS payment info text
          #html = render_to_string("partials/_smsPay.html.erb", layout: false)
          #@request.sms_guide_html = html
        end
        RequestNotifier.NewRequestInfo(@request).deliver
        return respond_with(@request, location: nil)
      rescue ActiveRecord::RecordNotUnique => e
        if (e.message.include? 'index_requests_on_url_and_email')
          errors << 'Sledování s touto adresou pro zadaný email je již jednou zadáno.'
          return respond_with({errors: errors}, status: :unprocessable_entity, location: nil)
        else
          raise $!
        end
      end
    else
      return respond_with({errors: errors}, status: :unprocessable_entity)
    end
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

  def do_url_check(url, errors)
    http_tool = HttpTool.new
    sreality = Sreality.new http_tool
    if url !~ URI::regexp
      errors << "Nesprávná url adresa, zkontrolujte, zda-li začíná znaky \"http://\""
    elsif url =~ /^http:\/\/www.sreality.cz\/?/
      errors << "Nelze sledovat všechny nemovitosti, nejdříve vyberte typ nemovitosti níže - např. Prodej bytů"
    elsif !sreality.is_url_valid?(url)
      errors << "Nesprávná url - můžete zadat pouze adresu vedoucí na server Sreality.cz,
          např. \"http://www.sreality.cz/search?category_type_cb=1&category_main_cb=1...\""
    else
      begin
        url = sreality.set_search_page_url_age_to(url, :all)
        page_info = sreality.get_page_summary(url)
        unless page_info
          errors << "Bohužel náš systém nebyl schopen tuto adresu zpracovat.
Chyba bude zřejmě na naší straně a nejsme schopni ji vyřešit ihned. Uložili jsme si ji a náš
team se jí bude co nejdříve zabývat."
        else
          return page_info
        end
      rescue
        logger.warn 'Error when getting search page summary'
        logger.warn $!
        errors << 'Chybná odpověď serveru, url adresa zřejmě nebude ve správném formátu.'
      end
    end
    return nil
  end

  def do_email_check(email, errors)
    emailok = @request.email =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
    unless emailok
      errors << 'Email není validní, nebo je špatném formátu.'
    end
  end
end