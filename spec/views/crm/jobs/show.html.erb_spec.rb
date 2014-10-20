require 'spec_helper'

describe 'crm/jobs/show.html.erb', job_spec: true, story_200: true do
  let!(:job) { build_stubbed :crm_job }

  it 'displays the name and description of the job' do
    assign(:job, job)
    render
    expect(rendered).to have_content job.name
    expect(rendered).to have_content job.description
  end
end