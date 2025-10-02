// See https://github.com/gmo-media/tofu-actions for syntax.

const commonConfig = {
  tfBinary: 'tofu',
  auth: {
    mode: 'aws-oidc',
    awsRegion: 'ap-northeast-1',
    awsPlanRole: 'arn:aws:iam::<aws-account-id>:role/tofu-plan',
    awsApplyRole: 'arn:aws:iam::<aws-account-id>:role/tofu-apply',
  },
};


export default {
  dirs: {
    'common': commonConfig,
    'dev': commonConfig,
  }
}
