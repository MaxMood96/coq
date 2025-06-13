- **Added:**
  error on ambiguous :cmd:`Require`. Rocq used to silently select a file
  when ambiguous :cmd:`Require`\s came from different loadpaths, for instance
  different fields of the ``ROCQPATH`` environment variable
  (`#20601 <https://github.com/rocq-prover/rocq/pull/20601>`_,
  fixes `#20587 <https://github.com/rocq-prover/rocq/issues/20587>`_,
  by Gaëtan Gilbert).
