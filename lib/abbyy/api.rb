module Abbyy
  module API
    
    API_METHODS = %w(process_image process_business_card get_task_status submit_image process_document).map(&:to_sym)
    
    def execute(sym, *args, &block)
      self.task_status = send("run_#{sym}", *args, &block)
      @status
    rescue RestClient::BlockedByWindowsParentalControls => ex
      raise Abbyy::IncorrectParameters.new(error(ex).message)
    rescue RestClient::RequestFailed => ex
      raise Abbyy::ProcessingFailed.new(error(ex).message)
    end
    
    def method_missing(sym, *args, &block)
      API_METHODS.include?(sym) ? execute(sym, *args, &block) : super
    end
    
    private
    
    # http://ocrsdk.com/documentation/apireference/processImage/
    def run_process_image(image_path, options = {})
      RestClient.post("#{@url}/processImage", options.merge(:upload => { :file => File.new(image_path, 'r') }))
    end
    
    # http://ocrsdk.com/documentation/apireference/processBusinessCard/
    def run_process_business_card(image_path, options = {})
      RestClient.post("#{@url}/processBusinessCard", options.merge(:upload => { :file => File.new(image_path, 'r') }))
    end
    
    # http://ocrsdk.com/documentation/apireference/submitImage/
    def run_submit_image(image_path, options = {})
      RestClient.post("#{@url}/submitImage", options.merge(:upload => { :file => File.new(image_path, 'r') }))
    end
    
    # http://ocrsdk.com/documentation/apireference/getTaskStatus/
    def run_get_task_status(task_id = @status[:id])
      RestClient.get("#{@url}/getTaskStatus?taskId=#{task_id}")
    end
    
    # http://ocrsdk.com/documentation/apireference/processDocument/
    def run_process_document(task_id = @status[:id])
      RestClient.get("#{@url}/processDocument?taskId=#{task_id}")
    end
    
  end
end

