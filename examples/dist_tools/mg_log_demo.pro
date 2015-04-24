; docformat = 'rst'

mg_log, name='mg_log_demo', logger=logger
logger->setProperty, level=5
mg_log, name='mg_log_demo/sub1', logger=sub1logger
sub1logger->setProperty, level=5
;mg_log, name='mg_log_demo/sub2', logger=sub2logger
;sub2logger->setProperty, level=4
mg_log, 'test', name='mg_log_demo', /debug
mg_log, 'test sub1', name='mg_log_demo/sub1', /debug
mg_log, 'test sub2', name='mg_log_demo/sub2', /debug

end
