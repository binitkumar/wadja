Country.create(:iso=>'en',:name=>'England')
Country.create(:iso=>'us',:name=>'USA')
Country.create(:iso=>'ind',:name=>'India')
Country.create(:iso=>'aus',:name=>'Australia')
Country.create(:iso=>'jpn',:name=>'Japan')

Type.create(:name=>'Ask')
Type.create(:name=>'Give')

Status.create(:name=>'Pending')
Status.create(:name=>'Approve')
Status.create(:name=>'Ignore')
Status.create(:name=>'Delete')
