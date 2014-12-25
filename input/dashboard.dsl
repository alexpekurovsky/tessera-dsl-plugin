graphite_prefix = "prefix"
%w{host1 host2 host3}.each do |host|
dashboard {
	title "#{host}"
	category "Monitoring"
	summary "Server monitoring"
	tags ["base", "idevelopment"]
	definition {
		section {
			row {
				cell {
					standard_time_series {
						title "CPU"
						max "100"
						query {
							name "cpu-host"
							target "groupByNode(#{graphite_prefix}.#{host}.cpu-*.cpu-{system,user},2,'sumSeries')"
						}
					}
				}
				cell {
					standard_time_series {
						title "Load Average"
						query {
							name "load-host"
							target "aliasByMetric(#{graphite_prefix}.#{host}.load.load.*)"
						}
					}
				}
				cell {
					standard_time_series {
						title "Memory"
						query {
							name "memory-host"
							target "alias(sumSeries(#{graphite_prefix}.#{host}.memory.memory-{buffered,cached,used}), 'memory')"
						}
					}
				}
				cell {
					standard_time_series {
						title "Disk, read/write"
						query {
							name "disk-host"
							target "aliasByNode(#{graphite_prefix}.#{host}.disk-sd[a-z].disk_time.*, 2, 4)"
						}
					}
				}
			}
			row {
				cell {
					stacked_area_chart {
						title "Disk usage: /"
						query {
							name "df-root-space"
							target "aliasByMetric(#{graphite_prefix}.#{host}.df-root.df_complex-{used,reseved,free})"
						}
					}
				}
			}
		}
	}
}
end
