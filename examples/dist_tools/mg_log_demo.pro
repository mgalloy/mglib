; docformat = 'rst'

mg_log, name='mg_log_demo', logger=logger
logger->setProperty, level=3

mg_log, name='mg_log_demo/sub1', logger=sub1logger
sub1logger->setProperty, level=5

mg_log, name='mg_log_demo/sub2', logger=sub2logger
sub2logger->setProperty, level=1

mg_log, 'test: should appear', name='mg_log_demo', /warn
mg_log, 'test: should not appear', name='mg_log_demo', /info

mg_log, 'test sub1: should appear', name='mg_log_demo/sub1', /debug

mg_log, 'test sub2: should appear', name='mg_log_demo/sub2', /warn
mg_log, 'test sub2: should not appear', name='mg_log_demo/sub2', /info

mg_log, 'test sub3: should appear', name='mg_log_demo/sub3', /warn
mg_log, 'test sub3: should not appear', name='mg_log_demo/sub3', /info

end
