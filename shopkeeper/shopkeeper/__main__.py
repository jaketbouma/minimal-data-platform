"""An AWS Python Pulumi program"""

import pulumi
import pulumi_aws
import logging

from shopkeeper.producer import testp

pulumi.export("testp", testp)

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

current = pulumi_aws.get_caller_identity()
logger.info(f"caller_account_id: {current.account_id}")
logger.info(f"caller_user_id: {current.user_id}")
