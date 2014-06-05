require 'spec_helper'

describe BoxView::Session, '#document_id' do

  it 'should raise error when document id is nil' do
    expect{BoxView.document_id}.to raise_error(BoxView::Errors::DocumentIdNotFound)
  end

end

describe BoxView::Session, '#expiration_date' do

  it 'should raise error when expiration date is nil' do
    expect{BoxView::Session.expiration_date}.to raise_error(BoxView::Errors::ExpirationDateNotFound)
  end

end