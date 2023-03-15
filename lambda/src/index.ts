import { SSMClient, GetParameterCommand } from '@aws-sdk/client-ssm';
import { SecretsManagerClient, GetSecretValueCommand } from '@aws-sdk/client-secrets-manager';
import axios from 'axios';
import { EC2Client, DescribeInstancesCommand } from '@aws-sdk/client-ec2';
import { MongoClient } from 'mongodb';

const ssmClient = new SSMClient({ region: 'us-west-2' });
const ec2Client = new EC2Client({ region: 'us-west-2' });
const secretsManagerClient = new SecretsManagerClient({ region: 'us-west-2' });

export const handler = async (event, context) => {
  console.log(event);

  try {

  } catch (error) {
    return {
      statusCode: 400,
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        message: 'Error Occurred',
      }),
    };
  }
};

