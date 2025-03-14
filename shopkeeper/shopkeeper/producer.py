import pulumi
import pulumi_aws
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

current = pulumi_aws.get_caller_identity()
logger.info(current.account_id)


class ProducerArgs:
    def __init__(self, name):
        self.name = name


class Producer(pulumi.ComponentResource):
    def __init__(self, name, args: ProducerArgs, opts=None):
        super().__init__("aws_datasets:Producer", name, None, opts)
        self.database = pulumi_aws.glue.CatalogDatabase(
            "producer_catalog",
            # catalog_id=current.account_id,
            name="producer_catalog_{name}",
            opts=pulumi.ResourceOptions(parent=self),
        )
        self.register_outputs({"database_arn": self.database.arn})

        self.color = my_component_args["color"]


testp = Producer("testp", my_component_args={"color": "red"})
