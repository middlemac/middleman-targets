activate :MiddlemanTargets

set :target, :pro

set :targets, {
  :free =>
      {
      :sample_key => 'People who use free versions don\'t drive profits.',
      :build_dir  => 'free_build (%s)',
      :features   =>
          {
          :feature_advertise_pro => true,
          :insults_user          => true,
          :grants_wishes         => false,
          }
      },

  :pro =>
      {
      :sample_key => 'You are a valued contributor to our balance sheet!',
      :features =>
          {
          :feature_advertise_pro => false,
          :insults_user          => false,
          :grants_wishes         => true,
          }
      },
}

set :target_magic_images, true
set :target_magic_word, 'all'

set :build_dir, 'custom_build_dir'
